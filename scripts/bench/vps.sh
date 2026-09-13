#!/usr/bin/env bash
# VPS CPU 对比基准：单核/多核性能、性能抖动、CPU steal（判断独享 vs 共享及共享程度）
# 用法：scp 到每台机器，sudo bash bench_vps.sh，把输出贴出来对比
# 注意：steal 只在"邻居正忙 + 母机超售"时才显现，务必在不同时段（尤其美东白天/晚高峰）多跑几次！

echo "===================== $(hostname) @ $(date -u '+%F %T UTC') ====================="

# 0) 依赖（sysbench 跑基准，sysstat 提供 mpstat 看 steal）
if ! command -v sysbench >/dev/null 2>&1 || ! command -v mpstat >/dev/null 2>&1; then
  echo "[*] installing sysbench + sysstat ..."
  { apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq sysbench sysstat; } >/dev/null 2>&1 \
    || { yum install -y -q sysbench sysstat; } >/dev/null 2>&1 \
    || { dnf install -y -q sysbench sysstat; } >/dev/null 2>&1 || true
fi
command -v sysbench >/dev/null 2>&1 || { echo "ERROR: 装不上 sysbench，手动装一下"; exit 1; }

NCPU=$(nproc)

# 1) CPU 基本信息（型号/主频/是否虚拟化）
echo; echo "### CPU info"
lscpu 2>/dev/null | grep -E 'Model name|^CPU\(s\)|Thread\(s\) per core|Core\(s\)|Socket|CPU max MHz|CPU MHz|BogoMIPS|Hypervisor|Virtualization' || true
echo "mem: $(free -h | awk '/Mem:/{print $2" total, "$7" avail"}')"

# 2) 单核性能（最相关：过 Cloudflare / 跑页面 JS 都是单线程重活）
echo; echo "### Single-thread (sysbench cpu, 1 thread, 15s)"
sysbench cpu --cpu-max-prime=20000 --threads=1 --time=15 run 2>/dev/null \
  | grep -E 'events per second' | sed 's/^ *//'

# 3) 多核性能（跑多个浏览器的总算力）
echo; echo "### Multi-thread (sysbench cpu, ${NCPU} threads, 15s)"
sysbench cpu --cpu-max-prime=20000 --threads="$NCPU" --time=15 run 2>/dev/null \
  | grep -E 'events per second' | sed 's/^ *//'

# 3b) 内存带宽（辅助：被超售母机的内存争用 / 异常慢内存能看出来。非主指标）
echo; echo "### Memory bandwidth (sysbench memory, ${NCPU} threads)"
sysbench memory --memory-block-size=1M --memory-total-size=20G --memory-oper=write \
  --threads="$NCPU" run 2>/dev/null | grep -E 'MiB/sec|transferred' | sed 's/^ *//'

# 4) 单核性能抖动（20 次短测）——抖动大 = 被邻居争用（即便此刻 steal 没显现也能看出来）
echo; echo "### Single-thread variance (20x) — stddev 越大越不稳"
for i in $(seq 1 20); do
  sysbench cpu --cpu-max-prime=10000 --threads=1 --time=2 run 2>/dev/null \
    | awk '/events per second/{print $4}'
done | awk '
  {a[NR]=$1; s+=$1; if(min==""||$1<min)min=$1; if($1>max)max=$1}
  END{ if(NR==0){print "no data"; exit}
    m=s/NR; for(i=1;i<=NR;i++){d=a[i]-m; v+=d*d}; sd=sqrt(v/NR);
    printf "mean=%.0f  stddev=%.0f (%.1f%%)  min=%.0f  max=%.0f  spread=%.1f%%\n", m, sd, 100*sd/m, min, max, 100*(max-min)/m }'

# 5) CPU steal 实测：满载全部核心 30s，同时用 mpstat 采样 —— %steal 是独享/共享的铁证
echo; echo "### CPU steal under full load (30s) — %steal=0 好；>0 即共享被偷，数值=被偷比例"
sysbench cpu --cpu-max-prime=20000 --threads="$NCPU" --time=30 run >/dev/null 2>&1 &
BG=$!
mpstat 1 30 2>/dev/null > /tmp/_mpstat.$$ || true
wait "$BG" 2>/dev/null
# 打印表头 + Average 行（%steal 一列对齐可读），并单独抓出平均 steal
grep -E '%idle' /tmp/_mpstat.$$ | head -1
grep -E 'Average' /tmp/_mpstat.$$ | tail -1
grep -E 'Average' /tmp/_mpstat.$$ | tail -1 | awk '{for(i=1;i<=NF;i++) if($i ~ /steal/) col=i} END{}' >/dev/null 2>&1
rm -f /tmp/_mpstat.$$

# 6) 运行队列 / 上下文切换（r 列远大于核数、或 st 列>0 = 争用）
echo; echo "### vmstat 1 5 (看 r=运行队列, st=steal)"
vmstat 1 5

echo "===================== done: $(hostname) ====================="
