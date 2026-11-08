#!/system/bin/sh
#
# 花風手写体 · 开机自检日志
# 把「字体到底有没有被接管」的结果写到：
#   /sdcard/Download/kafu_font_log.txt   （方便直接发出来排查）
#   /data/local/tmp/kafu_font_log.txt    （备用，root 可读）
#

MODDIR=${0%/*}
LOG1=/sdcard/Download/kafu_font_log.txt
LOG2=/data/local/tmp/kafu_font_log.txt

# 等 /sdcard 挂载/解锁完成（最多约 120 秒）
i=0
while [ $i -lt 60 ]; do
  if [ -d /sdcard/Download ] && echo > /sdcard/Download/.kafu_probe 2>/dev/null; then
    rm -f /sdcard/Download/.kafu_probe 2>/dev/null
    break
  fi
  sleep 2
  i=$((i + 1))
done

write_log() {
  echo "===== 花風手写体 自检 ====="
  echo "时间: $(date)"
  echo "机型: $(getprop ro.product.model) / $(getprop ro.product.device)"
  echo "系统: Android $(getprop ro.build.version.release) (SDK $(getprop ro.build.version.sdk)) $(getprop ro.miui.ui.version.name)"
  echo
  echo "----- 关键字体文件 -----"
  for f in Roboto-Regular.ttf RobotoStatic-Regular.ttf SourceSansPro-Regular.ttf MiSansVF.ttf MiSans-Regular.ttf MiSansL3.otf NotoSansCJK-Regular.ttc; do
    ls -l "/system/fonts/$f" 2>&1
    echo "     size=$(stat -c %s "/system/fonts/$f" 2>/dev/null)"
  done
  echo
  echo "----- /product/fonts -----"
  for f in MiSansVF.ttf MiSansL3.otf MiSansLatinVF.ttf MiSansTCVF.ttf MiSansJapaneseVF.ttf MiSansKoreanVF.ttf; do
    ls -l "/product/fonts/$f" 2>&1
    echo "     size=$(stat -c %s "/product/fonts/$f" 2>/dev/null)"
  done
  echo
  echo "----- 当前运行 App 实际 mmap 的字体 -----"
  for n in com.android.settings com.tencent.mm com.android.systemui com.miui.home; do
    for p in $(pidof $n); do
      echo "--- $n ($p)"
      grep -iE 'fonts|\.ttf|\.otf|\.ttc' /proc/$p/maps 2>/dev/null | sed 's/.* //' | sort -u
    done
  done
  echo
  echo "----- 属性 -----"
  for p in ro.miui.ui.fonttype ro.miui.ui.font.version ro.miui.ui.font.mi_font_path ro.miui.ui.font.mi_fonts_customization_xml ro.miui.ui.font.theme_apply; do
    echo "$p = $(getprop $p)"
  done
  echo
  echo "----- SystemFonts / Typeface 日志 -----"
  logcat -d -s SystemFonts Typeface 2>/dev/null | tail -40
  echo
  echo "===== 自检结束 ====="
}

write_log > "$LOG2" 2>&1
write_log > "$LOG1" 2>&1
chmod 0666 "$LOG1" "$LOG2" 2>/dev/null
exit 0
