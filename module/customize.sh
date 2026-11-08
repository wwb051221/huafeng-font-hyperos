##########################################################################################
# 花風手写体 · HyperOS 适配版 v8
# 适配 Magisk v20.4+ / HyperOS / MIUI（Android 13~17）
#
# 做法：安装时把唯一的字体母版 master/font.ttf 以「硬链接」方式映射成
# 系统实际会加载的每一个字体文件名，重启后由 Magisk 挂载到 /system/fonts 与 /product/fonts。
# 硬链接不额外占用空间；若文件系统不支持硬链接则自动退化为复制。
##########################################################################################

ui_print " "
ui_print " ********************************"
ui_print "  花風手写体"
ui_print "  HyperOS 全 App 覆盖版 v8"
ui_print " ********************************"

FONT="$MODPATH/master/font.ttf"
if [ ! -f "$FONT" ]; then
  abort "! 安装包不完整：缺少 master/font.ttf"
fi

# 设备实际加载、且需要被手写体接管的字体文件
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
NotoSansSC-Regular.ttf
"

# /product/fonts 是小米字体真实位置（App 进程直接 mmap 这里的文件）
PRODUCT_LIST="
MiSansVF.ttf
MiSansL3.otf
MiSansLatinVF.ttf
MiSansTCVF.ttf
MiSansJapaneseVF.ttf
MiSansKoreanVF.ttf
MiSans-Regular.ttf
Roboto-Regular.ttf
RobotoStatic-Regular.ttf
"

mkdir -p "$MODPATH/system/fonts" "$MODPATH/product/fonts"
ui_print "- 正在生成字体映射…"

COUNT=0
for f in $FONT_LIST; do
  if ln -f "$FONT" "$MODPATH/system/fonts/$f" 2>/dev/null; then
    :
  else
    cp -f "$FONT" "$MODPATH/system/fonts/$f"
  fi
  COUNT=$((COUNT + 1))
done

for f in $PRODUCT_LIST; do
  if ln -f "$FONT" "$MODPATH/product/fonts/$f" 2>/dev/null; then
    :
  else
    cp -f "$FONT" "$MODPATH/product/fonts/$f"
  fi
done

ui_print "- 已接管 $COUNT 个字体文件"
ui_print "- 重点覆盖：Roboto-Regular.ttf（英文/数字）、MiSansL3.otf（中文回退）"
ui_print "- 安装完成，请【完全重启】手机后生效"

##########################################################################################
# 权限
##########################################################################################
set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
}
