# 花風手写体 · HyperOS 适配版 v8

Magisk 字体模块，适用小米 / 红米 HyperOS、MIUI（Android 13 ~ 17），Magisk 20.4+。

## 覆盖范围

系统实际加载的字体文件全部替换为手写体（共 24 个）：

| 用途 | 文件 |
|---|---|
| 全部 App 默认字体（含设置 / 微信 / QQ） | `Roboto-Regular.ttf`、`Roboto-Italic.ttf`、`RobotoFlex-Regular.ttf`、`RobotoStatic-Regular.ttf` |
| 中文回退（关键） | `MiSansL3.otf` |
| 小米字体体系 | `MiSansVF.ttf`、`MiSansLatinVF.ttf`、`MiSansTCVF.ttf`、`MiSansJapaneseVF.ttf`、`MiSansKoreanVF.ttf`、`MiSans-Regular/Medium/Bold.ttf` |
| HyperOS UI | `SourceSansPro-Regular/Bold/SemiBold/Italic/BoldItalic/SemiBoldItalic.ttf` |
| 兼容旧接口 | `DroidSans.ttf`、`DroidSans-Bold.ttf`、`RobotoCondensed-*`、`NotoSansSC-Regular.ttf` |

同时覆盖 `/system/fonts` 与 `/product/fonts` 两处（小米字体实际存放在 `/product/fonts`，
`/system/fonts/MiSans*` 是指向它的软链接）。

## 安装

1. Magisk → 模块 → 从本地安装本 zip；
2. **完全重启**；
3. 若个别界面仍为旧字体：主题商店 → 字体 → 恢复「默认字体」，再重启一次。

## 验证

重启后自动生成 `/sdcard/Download/kafu_font_log.txt`（备用 `/data/local/tmp/kafu_font_log.txt`），
正常时关键字体大小应为 `23502360`：

```
/system/fonts/MiSansL3.otf        23502360
/system/fonts/Roboto-Regular.ttf  23502360
```

也可在 root 终端确认微信实际加载的字体：

```sh
cat /proc/$(pidof com.tencent.mm)/maps | grep -E 'MiSansL3|Roboto-Regular'
```

## 说明

- 手写体为单字重，粗体由系统伪粗体合成，属正常现象。
- 字库含 20976 个汉字（覆盖 GB2312/GBK 常用字）与拉丁字母、数字；生僻字自动回退系统 Noto。
- 未替换 serif / monospace / emoji 家族，避免表情与代码字体异常。
- 卸载：Magisk 中移除模块并重启即可恢复。

> 已实测：Xiaomi 14（houji / HyperOS 3 V816 / Android 16）刷入后，
> 系统设置、微信、Magisk 等 App 均正常显示手写体。
