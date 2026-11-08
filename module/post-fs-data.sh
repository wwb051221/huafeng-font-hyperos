#!/system/bin/sh
#
# 花風小手写体 · HyperOS 4 适配版 v8
# post-fs-data：在系统读取字体配置之前完成最后一步
#   1) 清理字体缓存，强制重新加载
#   2) 兜底：若安装阶段没有生成字体文件（例如安装脚本未执行），
#      直接把母版 bind mount 到 /system/fonts 下真实存在的字体文件
#

MODDIR=${0%/*}
FONT="$MODDIR/master/font.ttf"

# ------------------------------------------------------------------
# 1. 清理字体缓存
# ------------------------------------------------------------------
rm -rf /data/fontconfig 2>/dev/null
rm -rf /data/system/fonts 2>/dev/null
rm -rf /data/fonts 2>/dev/null

# ------------------------------------------------------------------
# 2. 兜底 bind mount
# ------------------------------------------------------------------
[ -f "$FONT" ] || exit 0
SIZE=$(stat -c %s "$FONT" 2>/dev/null)
[ -n "$SIZE" ] || exit 0

# 让 mipro / system_server 能正常读取（沿用系统字体的 SELinux 标签）
REF=/system/fonts/NotoColorEmoji.ttf
[ -f "$REF" ] || REF=/system/fonts/Roboto-Regular.ttf
if [ -f "$REF" ]; then
  CTX=$(ls -Zd "$REF" 2>/dev/null | awk '{print $1}')
  if [ -n "$CTX" ]; then
    chcon "$CTX" "$FONT" 2>/dev/null
  else
    chcon u:object_r:system_file:s0 "$FONT" 2>/dev/null
  fi
fi

FONT_LIST="
Roboto-Regular.ttf
Roboto-Italic.ttf
RobotoFlex-Regular.ttf
RobotoStatic-Regular.ttf
RobotoCondensed-Regular.ttf
RobotoCondensed-Italic.ttf
DroidSans.ttf
DroidSans-Bold.ttf
SourceSansPro-Regular.ttf
SourceSansPro-Bold.ttf
SourceSansPro-SemiBold.ttf
SourceSansPro-Italic.ttf
SourceSansPro-BoldItalic.ttf
SourceSansPro-SemiBoldItalic.ttf
MiSans-Regular.ttf
MiSans-Medium.ttf
MiSans-Bold.ttf
MiSansVF.ttf
MiSansLatinVF.ttf
MiSansTCVF.ttf
MiSansJapaneseVF.ttf
MiSansKoreanVF.ttf
MiSansL3.otf
"

for f in $FONT_LIST; do
  T="/system/fonts/$f"
  [ -e "$T" ] || continue
  # 已经由 Magisk 挂载成本模块字体（大小一致）则跳过
  [ "$(stat -c %s "$T" 2>/dev/null)" = "$SIZE" ] && continue
  mount --bind "$FONT" "$T" 2>/dev/null
done

# /product/fonts（小米字体真实位置，App 进程直接 mmap 这里的文件）
PRODUCT_LIST="MiSansVF.ttf MiSansL3.otf MiSansLatinVF.ttf MiSansTCVF.ttf MiSansJapaneseVF.ttf MiSansKoreanVF.ttf MiSans-Regular.ttf Roboto-Regular.ttf RobotoStatic-Regular.ttf"
for f in $PRODUCT_LIST; do
  T="/product/fonts/$f"
  [ -e "$T" ] || continue
  [ "$(stat -c %s "$T" 2>/dev/null)" = "$SIZE" ] && continue
  mount --bind "$FONT" "$T" 2>/dev/null
done

exit 0
