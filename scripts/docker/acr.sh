# GitHub repo that hosts the mirror workflow and records pushed images.
ACR_GH_REPO="docker-acr-mirror"

# Prefix used for the git tags that record images pushed to ACR.
ACR_TAG_PREFIX="docker-images"

usage_acr() {
  cat <<-EOF
Usage: docker acr <command> [args]

Mirror Docker Hub images to Aliyun ACR via GitHub Actions.
An image is pulled on a GitHub Actions runner (outside China) and
pushed to ACR, then you can pull it from ACR at full speed. Each
successful push is recorded as a git tag ($ACR_TAG_PREFIX/...) so the
pushed images can be listed later without querying ACR directly.

Commands:
  push <image> [<acr_tag>]   Pull an image on a runner and push it to ACR
  list                       List images already pushed to ACR
  login                      (Re)set ACR credentials (username/password) on GitHub

Config (env vars):
  DOCKER_ACR_REGISTRY   ACR registry, default is registry.cn-shanghai.aliyuncs.com
  DOCKER_ACR_NAMESPACE  ACR namespace

Examples:
  $ docker acr push mysql:8.0.39
  $ docker acr push nginx:alpine myns/nginx:alpine
  $ docker acr list
  $ docker acr login              # after switching to a different ACR account
EOF
  exit 1
}

_acr_load_config() {
  DOCKER_ACR_REGISTRY="${DOCKER_ACR_REGISTRY:-registry.cn-shanghai.aliyuncs.com}"
  DOCKER_ACR_NAMESPACE="${DOCKER_ACR_NAMESPACE:-}"

  if [ -z "$DOCKER_ACR_NAMESPACE" ]; then
    echo "Error: DOCKER_ACR_NAMESPACE is not set."
    echo "Export it as an env var, e.g. in ~/.zshrc.local:"
    echo "  export DOCKER_ACR_NAMESPACE=<your-acr-namespace>"
    exit 1
  fi
}

_acr_ensure_repo() {
  local repo="$ACR_GH_REPO"

  echo "Checking GitHub repo: $repo ..."
  if ! gh repo view "$repo" &>/dev/null; then
    echo "Creating GitHub repo: $repo ..."
    gh repo create "$repo" --private --add-readme
    echo "Repo created."
  else
    echo "Repo already exists."
  fi

  # Upload workflow file via API (no clone needed)
  echo "Uploading workflow file..."
  local workflow_path=".github/workflows/acr_push.yml"
  # NOTE: captured via `read -d ''` rather than $(cat <<EOF) because bash 3.2
  # (macOS) mis-parses a heredoc containing `case`/`;;` inside $( ).
  local workflow_content
  IFS='' read -r -d '' workflow_content << 'WORKFLOW' || true
name: Push to ACR

on:
  workflow_dispatch:
    inputs:
      source_image:
        description: 'Source image on Docker Hub'
        required: true
      target_image:
        description: 'Target image on ACR (full path without registry prefix)'
        required: true

jobs:
  push:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4

      - name: Login to ACR
        run: |
          echo "${{ secrets.ACR_PASSWORD }}" | \
            docker login "${{ secrets.ACR_REGISTRY }}" \
              -u "${{ secrets.ACR_USERNAME }}" --password-stdin

      - name: Pull, tag and push
        run: |
          docker pull "${{ github.event.inputs.source_image }}"
          docker tag "${{ github.event.inputs.source_image }}" \
            "${{ secrets.ACR_REGISTRY }}/${{ github.event.inputs.target_image }}"
          docker push \
            "${{ secrets.ACR_REGISTRY }}/${{ github.event.inputs.target_image }}"

      - name: Record pushed image as a git tag
        if: success()
        run: |
          ref="${{ github.event.inputs.target_image }}"
          # Encode "repo:tag" as "docker-images/repo/tag" (":" is illegal in refs).
          case "$ref" in
            *:*) tag="docker-images/${ref%:*}/${ref##*:}" ;;
            *)   tag="docker-images/$ref/latest" ;;
          esac
          git tag -f "$tag"
          git push -f origin "$tag"

      - name: Print pull command
        run: |
          echo ""
          echo "Done! Pull with:"
          echo "  docker pull ${{ secrets.ACR_REGISTRY }}/${{ github.event.inputs.target_image }}"
WORKFLOW

  local encoded
  encoded=$(echo "$workflow_content" | base64 | tr -d '\n')

  # Get existing file SHA if it exists (needed for update)
  local sha
  sha=$(gh api "repos/{owner}/$repo/contents/$workflow_path" --jq '.sha' 2>/dev/null || true)

  local payload
  if [ -n "$sha" ]; then
    payload=$(jq -n --arg msg "update acr_push workflow" --arg content "$encoded" --arg sha "$sha" \
      '{message: $msg, content: $content, sha: $sha}')
  else
    payload=$(jq -n --arg msg "add acr_push workflow" --arg content "$encoded" \
      '{message: $msg, content: $content}')
  fi

  echo "$payload" | gh api "repos/{owner}/$repo/contents/$workflow_path" \
    --method PUT --input - >/dev/null
  echo "Workflow file uploaded."
}

_acr_ensure_secrets() {
  local repo="$ACR_GH_REPO"
  local full_repo
  full_repo="$(gh repo view "$repo" --json nameWithOwner --jq '.nameWithOwner')"

  for secret in ACR_USERNAME ACR_PASSWORD; do
    if ! gh secret list --repo "$full_repo" 2>/dev/null | grep -q "^$secret"; then
      echo "Secret $secret is not set."
      printf "Enter value for $secret: "
      read -rs value
      echo
      gh secret set "$secret" --repo "$full_repo" --body "$value"
    fi
  done

  # Always sync registry and namespace from local config
  gh secret set ACR_REGISTRY  --repo "$full_repo" --body "$DOCKER_ACR_REGISTRY"
  gh secret set ACR_NAMESPACE --repo "$full_repo" --body "$DOCKER_ACR_NAMESPACE"
}

_acr_normalize_tag() {
  local image="$1"
  # Strip registry prefix if present (e.g. docker.io/library/nginx -> nginx)
  image="${image#docker.io/}"
  image="${image#library/}"
  # ACR only supports one level: replace / with - (e.g. foo/bar -> foo-bar)
  echo "${image//\//-}"
}

cmd_acr_push() {
  [ "$1" = "-h" ] && usage_acr

  local source_image="$1"
  local target_tag="$2"

  if [ -z "$source_image" ]; then
    usage_acr
  fi

  _acr_load_config

  # Default target tag: namespace/image (normalized)
  if [ -z "$target_tag" ]; then
    target_tag="$DOCKER_ACR_NAMESPACE/$(_acr_normalize_tag "$source_image")"
  elif [[ "$target_tag" != */* ]]; then
    target_tag="$DOCKER_ACR_NAMESPACE/$target_tag"
  fi

  echo "Source : $source_image"
  echo "Target : $DOCKER_ACR_REGISTRY/$target_tag"
  echo ""

  _acr_ensure_repo
  _acr_ensure_secrets

  local full_repo
  full_repo="$(gh repo view "$ACR_GH_REPO" --json nameWithOwner --jq '.nameWithOwner')"

  echo "Triggering GitHub Actions workflow..."
  gh workflow run acr_push.yml \
    --repo "$full_repo" \
    --field "source_image=$source_image" \
    --field "target_image=$target_tag"

  echo "Waiting for workflow to complete..."
  sleep 3
  gh run watch --repo "$full_repo" --exit-status

  echo ""
  echo "Pull with:"
  echo "  docker pull $DOCKER_ACR_REGISTRY/$target_tag"
}

cmd_acr_list() {
  [ "$1" = "-h" ] && usage_acr

  _acr_load_config

  local full_repo
  full_repo="$(gh repo view "$ACR_GH_REPO" --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null || true)"
  if [ -z "$full_repo" ]; then
    echo "GitHub repo '$ACR_GH_REPO' not found."
    echo "Push an image first: docker acr push <image>"
    exit 1
  fi

  local refs
  refs="$(gh api "repos/$full_repo/git/matching-refs/tags/$ACR_TAG_PREFIX/" \
    --jq '.[].ref' 2>/dev/null || true)"

  if [ -z "$refs" ]; then
    echo "No images recorded yet in $full_repo."
    exit 0
  fi

  echo "Images pushed to $DOCKER_ACR_REGISTRY:"
  echo ""
  {
    local ref rest repo tag
    while IFS= read -r ref; do
      rest="${ref#refs/tags/$ACR_TAG_PREFIX/}"
      # Last path segment is the docker tag; the rest is the repository.
      tag="${rest##*/}"
      repo="${rest%/*}"
      echo "  $DOCKER_ACR_REGISTRY/$repo:$tag"
    done <<< "$refs"
  } | sort
}

cmd_acr_login() {
  [ "$1" = "-h" ] && usage_acr

  _acr_load_config

  local full_repo
  full_repo="$(gh repo view "$ACR_GH_REPO" --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null || true)"
  if [ -z "$full_repo" ]; then
    echo "GitHub repo '$ACR_GH_REPO' not found."
    echo "Push an image first: docker acr push <image>"
    exit 1
  fi

  local username password
  printf "ACR_USERNAME: "
  read -r username
  printf "ACR_PASSWORD: "
  read -rs password
  echo

  gh secret set ACR_USERNAME  --repo "$full_repo" --body "$username"
  gh secret set ACR_PASSWORD  --repo "$full_repo" --body "$password"
  gh secret set ACR_REGISTRY  --repo "$full_repo" --body "$DOCKER_ACR_REGISTRY"
  gh secret set ACR_NAMESPACE --repo "$full_repo" --body "$DOCKER_ACR_NAMESPACE"

  echo "ACR credentials updated for $full_repo ($DOCKER_ACR_REGISTRY/$DOCKER_ACR_NAMESPACE)."
}

cmd_acr() {
  local sub="$1"
  [ "$#" -gt 0 ] && shift

  case "$sub" in
    push)
      cmd_acr_push "$@"
      ;;
    list | ls)
      cmd_acr_list "$@"
      ;;
    login)
      cmd_acr_login "$@"
      ;;
    *)
      usage_acr
      ;;
  esac
}
