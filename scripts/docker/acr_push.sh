usage_acr_push() {
  cat <<-EOF
Usage: docker acr_push <image> [<acr_tag>]

Push a Docker Hub image to Aliyun ACR via GitHub Actions.
The image is pulled on a GitHub Actions runner (outside China) and
pushed to ACR, then you can pull it from ACR at full speed.

Arguments:
  image    Source image on Docker Hub, e.g. mysql:8.0.39
  acr_tag  Target tag on ACR (optional, defaults to <image>)

Config (env vars or ~/.docker-acr):
  DOCKER_ACR_REGISTRY   ACR registry, e.g. registry.cn-shanghai.aliyuncs.com
  DOCKER_ACR_NAMESPACE  ACR namespace
  DOCKER_ACR_GH_REPO    GitHub repo used for the workflow (default: docker-acr-mirror)

Examples:
  $ docker acr_push mysql:8.0.39
  $ docker acr_push nginx:alpine myns/nginx:alpine
EOF
  exit 1
}

_acr_push_load_config() {
  local config_file="$HOME/.docker-acr"
  [ -f "$config_file" ] && source "$config_file"

  DOCKER_ACR_REGISTRY="${DOCKER_ACR_REGISTRY:-registry.cn-shanghai.aliyuncs.com}"
  DOCKER_ACR_NAMESPACE="${DOCKER_ACR_NAMESPACE:-}"
  DOCKER_ACR_GH_REPO="${DOCKER_ACR_GH_REPO:-docker-acr-mirror}"

  if [ -z "$DOCKER_ACR_NAMESPACE" ]; then
    echo "Error: DOCKER_ACR_NAMESPACE is not set."
    echo "Set it in ~/.docker-acr or as an env var."
    exit 1
  fi
}

_acr_push_ensure_repo() {
  local repo="$DOCKER_ACR_GH_REPO"

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
  local workflow_content
  workflow_content=$(cat << 'WORKFLOW'
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
    steps:
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

      - name: Print pull command
        run: |
          echo ""
          echo "Done! Pull with:"
          echo "  docker pull ${{ secrets.ACR_REGISTRY }}/${{ github.event.inputs.target_image }}"
WORKFLOW
)

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

_acr_push_ensure_secrets() {
  local repo="$DOCKER_ACR_GH_REPO"
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

_acr_push_normalize_tag() {
  local image="$1"
  # Strip registry prefix if present (e.g. docker.io/library/nginx -> nginx)
  image="${image#docker.io/}"
  image="${image#library/}"
  # ACR only supports one level: replace / with - (e.g. foo/bar -> foo-bar)
  echo "${image//\//-}"
}

cmd_acr_push() {
  local source_image="$1"
  local target_tag="$2"

  if [ -z "$source_image" ]; then
    usage_acr_push
  fi

  _acr_push_load_config

  # Default target tag: namespace/image (normalized)
  if [ -z "$target_tag" ]; then
    target_tag="$DOCKER_ACR_NAMESPACE/$(_acr_push_normalize_tag "$source_image")"
  elif [[ "$target_tag" != */* ]]; then
    target_tag="$DOCKER_ACR_NAMESPACE/$target_tag"
  fi

  echo "Source : $source_image"
  echo "Target : $DOCKER_ACR_REGISTRY/$target_tag"
  echo ""

  _acr_push_ensure_repo
  _acr_push_ensure_secrets

  local full_repo
  full_repo="$(gh repo view "$DOCKER_ACR_GH_REPO" --json nameWithOwner --jq '.nameWithOwner')"

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
