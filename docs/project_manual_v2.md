# QLaw Markdown 缂栬緫鍣?鈥?椤圭洰璇存槑涓庝娇鐢ㄦ墜鍐?

> 鐗堟湰 1.1.0 | 鏇存柊鏃ユ湡锛?026-06-23
> 椤圭洰鍦板潃锛歨ttps://github.com/MingQiangChen/markdown_editor55

---

## 涓€銆侀」鐩畝浠?

QLaw Markdown 鏄竴娆惧熀浜?Flutter 寮€鍙戠殑璺ㄥ钩鍙?Markdown 缂栬緫鍣紝鏀寔 Windows銆乵acOS銆丩inux 妗岄潰绔€乄eb 绔互鍙?Android 鍜?iOS 绉诲姩绔€傞潰鍚戦渶瑕侀珮鏁堝啓浣滅殑寮€鍙戣€呫€佸鐢熷拰鐮旂┒浜哄憳锛屾彁渚涘疄鏃堕瑙堛€佹暟瀛﹀叕寮忔覆鏌撱€丮ermaid 鍥捐〃銆佷簯鍚屾绛夊姛鑳姐€?

### 鏍稿績鐗圭偣

- 馃枈锔?**鎵€瑙佸嵆鎵€寰?*锛氱紪杈戞椂瀹炴椂棰勮娓叉煋鏁堟灉
- 馃搻 **鏁板鍏紡**锛氳鍐?`$...$` 鍜屽潡绾?`$$...$$`锛屽熀浜?KaTeX 娓叉煋
- 馃搳 **Mermaid 鍥捐〃**锛氭祦绋嬪浘銆佹椂搴忓浘銆佺敇鐗瑰浘绛夊疄鏃舵覆鏌?
- 馃搧 **鏂囦欢鏍?*锛氶」鐩骇鏂囦欢娴忚涓庣鐞?
- 馃柤锔?**鍥剧墖鎻掑叆**锛氬彲瑙嗗寲鍥剧墖鎻掑叆瀵硅瘽妗?
- 鈽侊笍 **浜戝悓姝?*锛歐ebDAV 鍚屾 + 鏈湴澶囦唤
- 馃搫 **PDF 瀵煎嚭**锛氭敮鎸佷腑鏂囧瓧浣擄紝12 绉?CSS 妯℃澘
- 馃寵 **娣辫壊/娴呰壊涓婚**锛氫竴閿垏鎹?
- 馃攳 **鎷煎啓妫€鏌?*锛氳嫳鏂囧疄鏃舵嫾鍐欐鏌ヤ笌寤鸿
- 鈱笍 **涓板瘜蹇嵎閿?*锛氭牸寮忓寲銆佹枃浠舵搷浣溿€佽鍥惧垏鎹?

---

## 浜屻€佹敮鎸佸钩鍙?

| 骞冲彴 | 杩愯鏂瑰紡 | 鐘舵€?|
|------|----------|------|
| Windows 10/11 | 妗岄潰搴旂敤 / Web | 鉁?宸查獙璇?|
| macOS 10.14+ | 妗岄潰搴旂敤 | 鉁?CI 閫氳繃 |
| Linux (Ubuntu 20.04+) | 妗岄潰搴旂敤 | 鉁?CI 閫氳繃 |
| Web (Chrome/Edge) | 娴忚鍣ㄨ闂?| 鉁?宸查獙璇?|

---

## 涓夈€佸畨瑁呬笌鍚姩

### 3.1 鐜瑕佹眰

- Flutter SDK 鈮?3.7.2
- Dart SDK 鈮?3.7.2
- Windows 妗岄潰鐗堥澶栭渶瑕侊細Visual Studio 2022锛堝惈 C++ 妗岄潰寮€鍙戝伐浣滆礋杞斤級
- Linux 妗岄潰鐗堥澶栭渶瑕侊細`clang cmake ninja-build pkg-config libgtk-3-dev`

### 3.2 鑾峰彇椤圭洰

```bash
git clone https://github.com/MingQiangChen/markdown_editor55.git
cd markdown_editor55
flutter pub get
```

### 3.3 鍚姩鏂瑰紡

**Web 妯″紡锛堟帹鑽愬揩閫熶綋楠岋級锛?*
```bash
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=5173
```
娴忚鍣ㄦ墦寮€ `http://127.0.0.1:5173`

**Windows 妗岄潰锛?*
```bash
flutter run -d windows
```

**Linux 妗岄潰锛?*
```bash
flutter run -d linux
```

**macOS 妗岄潰锛?*
```bash
flutter run -d macos
```

### 3.4 鏋勫缓 Release 鐗堟湰

```bash
# Windows
flutter build windows --release
# 浜х墿鍦?build/windows/x64/runner/Release/

# Linux
flutter build linux --release

# macOS
flutter build macos --release

# Web
flutter build web --release
```

---

## 鍥涖€佸姛鑳借瑙?

### 4.1 缂栬緫鍣ㄦ牳蹇?

#### 涓荤晫闈㈠竷灞€
- **瀹藉睆锛堚墺600px锛?*锛氱紪杈戝尯涓庨瑙堝尯宸﹀彸鍒嗗睆鏄剧ず
- **绐勫睆锛?600px锛?*锛氱紪杈戜笌棰勮鍒嗛〉鍒囨崲

#### 鏍煎紡鍖栧伐鍏锋爮

| 鎸夐挳 | 鍔熻兘 | Markdown 璇硶 |
|------|------|--------------|
| Heading | 鎻掑叆鏍囬 | `## ` |
| Bold | 鍔犵矖 | `**鏂囨湰**` |
| Italic | 鏂滀綋 | `*鏂囨湰*` |
| Inline Code | 琛屽唴浠ｇ爜 | `` `浠ｇ爜` `` |
| Link | 鎻掑叆閾炬帴 | `[鏂囨湰](URL)` |
| Quote | 寮曠敤 | `> ` |
| List | 鏃犲簭鍒楄〃 | `- ` |
| Code Block | 浠ｇ爜鍧?| ` ``` ` |
| Inline Math | 琛屽唴鍏紡 | `$鍏紡$` |
| Math Block | 鍧楃骇鍏紡 | `$$鍏紡$$` |
| Mermaid | Mermaid 鍥捐〃 | `` ```mermaid `` |
| Spell Check | 鎷煎啓妫€鏌ュ紑鍏?| 鈥?|
| Code Snippets | 浠ｇ爜鐗囨锛堝垎鍓茬嚎銆佽〃鏍笺€佸叕寮忕瓑锛?| 鈥?|
| Image | 鎻掑叆鍥剧墖 | `![鎻忚堪](璺緞)` |

#### 閿洏蹇嵎閿?

**鏍煎紡鍖栵細**

| 蹇嵎閿?| 鍔熻兘 |
|--------|------|
| `Ctrl+B` | 鍔犵矖 |
| `Ctrl+I` | 鏂滀綋 |
| `Ctrl+`` ` | 琛屽唴浠ｇ爜 |
| `Ctrl+K` | 鎻掑叆閾炬帴 |

**鏂囦欢鎿嶄綔锛?*

| 蹇嵎閿?| 鍔熻兘 |
|--------|------|
| `Ctrl+S` | 淇濆瓨 |
| `Ctrl+O` | 鎵撳紑鏂囦欢 |
| `Ctrl+N` | 鏂板缓鏂囨。 |

**缂栬緫锛?*

| 蹇嵎閿?| 鍔熻兘 |
|--------|------|
| `Ctrl+F` | 鏌ユ壘鍜屾浛鎹?|

**瑙嗗浘锛?*

| 蹇嵎閿?| 鍔熻兘 |
|--------|------|
| `Ctrl+Shift+P` | 鍒囨崲棰勮鏄剧ず |
| `Ctrl+Shift+V` | 寰幆鍒囨崲瑙嗗浘妯″紡 |
| `Alt+Z` | 鍒囨崲鑷姩鎹㈣ |

**鏍囩椤碉細**

| 蹇嵎閿?| 鍔熻兘 |
|--------|------|
| `Ctrl+Tab` | 涓嬩竴涓爣绛鹃〉 |
| `Ctrl+Shift+Tab` | 涓婁竴涓爣绛鹃〉 |
| `Ctrl+W` | 鍏抽棴褰撳墠鏍囩椤?|

### 4.2 澶氭爣绛炬枃妗?

- 鐐瑰嚮 `+` 鎴?`Ctrl+N` 鏂板缓鏍囩椤?
- 鐐瑰嚮鏍囩椤靛垏鎹㈡枃妗?
- 鍏抽棴鏈夋湭淇濆瓨鏇存敼鐨勬爣绛鹃〉鏃跺脊鍑虹‘璁ゅ璇濇
- 姣忎釜鏍囩椤电嫭绔嬬淮鎶ょ紪杈戠姸鎬?

### 4.3 鏂囦欢鎿嶄綔

- **鎵撳紑**锛氱偣鍑?Open 鎴?`Ctrl+O`锛屼粎鏄剧ず `.md` 鏂囦欢锛涙敮鎸佹嫋鎷?`.md` 鏂囦欢鍒扮獥鍙ｆ墦寮€
- **淇濆瓨**锛氱偣鍑?Save 鎴?`Ctrl+S`锛屾墦寮€鍙﹀瓨涓哄璇濇纭鏂囦欢鍚嶅拰浣嶇疆
- **鏈€杩戞枃浠?*锛氭渶澶氫繚鐣?10 鏉¤褰曪紝鎸夋渶杩戞墦寮€鏃堕棿鎺掑簭
- **澶栭儴鍙樻洿妫€娴?*锛氬綋鏂囦欢琚閮ㄧ▼搴忎慨鏀规椂锛屽脊鍑哄啿绐佸璇濇

### 4.4 鏂囦欢鏍戯紙鏂板姛鑳斤級

- 宸︿晶鏂囦欢鏍戦潰鏉匡紝娴忚褰撳墠椤圭洰鐩綍
- 鐐瑰嚮鏂囦欢鍚嶇洿鎺ユ墦寮€缂栬緫
- 鏀寔灞曞紑/鎶樺彔鐩綍

### 4.5 鍥剧墖鎻掑叆

- 宸ュ叿鏍忕偣鍑?Image 鎸夐挳鎵撳紑鍥剧墖鎻掑叆瀵硅瘽妗?
- 鏀寔鏈湴鏂囦欢閫夋嫨锛屽浘鐗囪嚜鍔ㄤ繚瀛樺埌鏂囨。鍚岀洰褰?`images/` 鏂囦欢澶?
- 鏀寔杈撳叆鍥剧墖 URL 鍜屾浛浠ｆ枃鏈?
- 鑷姩鐢熸垚 Markdown 鍥剧墖璇硶 `![鎻忚堪](璺緞)`
- 鏀寔鎷栨斁鍥剧墖鏂囦欢鍒扮紪杈戝櫒绐楀彛

### 4.6 琛ㄦ牸缂栬緫鍣紙鏂板姛鑳斤級

- 鍙鍖栬〃鏍肩紪杈戠晫闈?
- 鏀寔娣诲姞/鍒犻櫎琛屽垪
- 鑷姩鐢熸垚 Markdown 琛ㄦ牸璇硶

### 4.7 浠诲姟鍒楄〃锛堟柊鍔熻兘锛?

- 鏀寔 `- [ ]` 鍜?`- [x]` 璇硶
- 鍦ㄩ瑙堜腑鍙洿鎺ュ嬀閫?鍙栨秷浠诲姟

### 4.8 鏁板鍏紡

- **琛屽唴鍏紡**锛氱敤 `$...$` 鍖呰９锛屽 `$E=mc^2$`
- **鍧楃骇鍏紡**锛氱敤 `$$...$$` 鍖呰９锛屽锛?
  ```
  $$
  \int_0^\infty e^{-x^2} dx = \frac{\sqrt{\pi}}{2}
  $$
  ```
- 瀹炴椂棰勮鍩轰簬 KaTeX 娓叉煋
- 瀵煎嚭鏃跺彲閫夊惎鐢?KaTeX 鏁板鍏紡娓叉煋

### 4.9 Mermaid 鍥捐〃

鏀寔 Mermaid.js 璇硶锛屽疄鏃堕瑙堟覆鏌擄細

```mermaid
graph TD
    A[寮€濮媇 --> B{鍒ゆ柇}
    B -->|鏄瘄 C[鎵ц]
    B -->|鍚 D[缁撴潫]
```

鏀寔鐨勫浘琛ㄧ被鍨嬶細娴佺▼鍥俱€佹椂搴忓浘銆佺敇鐗瑰浘銆侀ゼ鍥俱€佺被鍥剧瓑銆?

瀵煎嚭鏃跺彲閫夊惎鐢?Mermaid 娓叉煋锛堥渶瑕佺綉缁滆繛鎺ュ姞杞?CDN 璧勬簮锛夈€?

### 4.10 鏌ユ壘鍜屾浛鎹?

- `Ctrl+F` 鎵撳紑鏌ユ壘鏍?
- 瀹炴椂鍖归厤骞舵樉绀哄尮閰嶆暟閲?
- 鏀寔澶у皬鍐欐晱鎰熷垏鎹?
- 涓?涓嬪鑸尮閰嶉」
- 鏇挎崲褰撳墠鍖归厤鎴栧叏閮ㄦ浛鎹?

### 4.11 鏂囨。澶х翰

- 宸ュ叿鏍忕偣鍑诲垪琛ㄥ浘鏍囨墦寮€澶х翰闈㈡澘
- 鑷姩瑙ｆ瀽 H1-H6 鏍囬
- 鎸夊眰绾х缉杩涙樉绀?
- 鐐瑰嚮鏍囬璺宠浆鍒板搴斾綅缃?

### 4.12 鍏ㄥ睆妯″紡

- 宸ュ叿鏍忕偣鍑诲叏灞忓浘鏍囪繘鍏?
- 闅愯棌宸ュ叿鏍忓拰鏍囩鏍忥紝鍙繚鐣欑紪杈戝尯鍜屾渶灏忕姸鎬佹爮
- `Esc` 閫€鍑哄叏灞?

### 4.13 瀵煎嚭

#### HTML 瀵煎嚭
瀵煎嚭涓哄甫鍐呭祵鏍峰紡鐨勫畬鏁?HTML 椤甸潰銆?

#### PDF 瀵煎嚭
- 鏀寔涓枃瀛椾綋锛圫imHei 榛戜綋锛?
- A4 椤甸潰鏍煎紡锛?2pt 椤佃竟璺?
- 鏀寔鏍囬銆佸垪琛ㄣ€佸紩鐢ㄣ€佷唬鐮佸潡銆佷换鍔″垪琛ㄣ€佽〃鏍肩瓑

#### CSS 妯℃澘锛?2 绉嶏級
| 妯℃澘 | 椋庢牸 |
|------|------|
| Default | 榛樿鐧借壊 |
| Dark | 娣辫壊涓婚 |
| Minimal | 鏋佺畝椋庢牸 |
| GitHub | GitHub 椋庢牸 |
| Solarized | Solarized 閰嶈壊 |
| Nord | Nord 閰嶈壊 |
| Dracula | Dracula 閰嶈壊 |
| Academic | 瀛︽湳璁烘枃 |
| Technical | 鎶€鏈枃妗?|
| Newspaper | 鎶ョ焊鎺掔増 |
| Presentation | 婕旂ず鏂囩 |
| Notion | Notion 椋庢牸 |

### 4.14 浜戝悓姝?

#### WebDAV 鍚屾
- 鏀寔鍧氭灉浜戙€丯extcloud 绛?WebDAV 鏈嶅姟
- 閰嶇疆椤癸細鏈嶅姟鍣ㄥ湴鍧€銆佺敤鎴峰悕/瀵嗙爜銆佽繙绋嬭矾寰?
- 鏀寔鑷姩鍚屾锛堝彲璁剧疆鍚屾闂撮殧锛?

#### 鏈湴澶囦唤
- 鍚屾鍒版湰鍦版寚瀹氱洰褰?
- 鍙墜鍔ㄨ緭鍏ヨ矾寰勬垨閫氳繃鏂囦欢澶归€夋嫨鍣ㄩ€夋嫨

#### 鍚屾鐘舵€?
- 闈㈡澘搴曢儴鏄剧ず鍚屾鐘舵€併€佷笂娆″悓姝ユ椂闂淬€佸悓姝ュ巻鍙?

### 4.15 鎷煎啓妫€鏌?

- 瀹炴椂妫€娴嬭嫳鏂囨嫾鍐欓敊璇紙绾㈣壊涓嬪垝绾挎爣璁帮級
- 缂栬緫鍣ㄤ笅鏂规樉绀烘嫾鍐欓敊璇垪琛?
- 鎻愪緵鎷煎啓寤鸿锛岀偣鍑诲嵆鍙嚜鍔ㄦ浛鎹?
- 鈿狅笍 鐩墠浠呮敮鎸佽嫳鏂?

### 4.16 璁剧疆闈㈡澘

| 璁剧疆椤?| 閫夐」 |
|--------|------|
| 瀛椾綋澶у皬 | 10-24 鍙?|
| 瀛椾綋 | 榛樿 / Consolas / Courier New / Monaco / Source Code Pro |
| Tab 缂╄繘 | 2 鎴?4 涓┖鏍?|
| 榛樿瑙嗗浘妯″紡 | 缂栬緫 / 鍒嗗睆 / 棰勮 |
| 鑷姩鎹㈣ | 寮€ / 鍏?|
| 鑷姩淇濆瓨闂撮殧 | 200-2000 姣 |

璁剧疆鍗虫椂鐢熸晥锛岃嚜鍔ㄤ繚瀛樸€?

### 4.17 鐘舵€佹爮

鏄剧ず淇℃伅锛氭枃浠跺悕 路 璇嶆暟 路 瀛楃鏁?路 淇濆瓨鐘舵€?路 瑙嗗浘妯″紡 路 鎹㈣鐘舵€?路 琛屽彿:鍒楀彿

绀轰緥锛?
```
report.md 路 350 words 路 2800 chars 路 Saved 路 Split view 路 Wrap 路 Ln 42, Col 15
```

---

## 浜斻€佹暟鎹瓨鍌ㄤ綅缃?

| 鏁版嵁 | Windows | Linux | macOS | Web |
|------|---------|-------|-------|-----|
| 鑽夌 | `%APPDATA%\QLawMarkdown\draft.md` | `~/.config/QLawMarkdown/draft.md` | `~/Library/Application Support/QLawMarkdown/draft.md` | localStorage |
| 鏈€杩戞枃浠?| `%APPDATA%\QLawMarkdown\recent.json` | `~/.config/QLawMarkdown/recent.json` | `~/Library/Application Support/QLawMarkdown/recent.json` | localStorage |
| 璁剧疆 | `%APPDATA%\QLawMarkdown\settings.json` | `~/.config/QLawMarkdown/settings.json` | `~/Library/Application Support/QLawMarkdown/settings.json` | localStorage |

> 娉ㄦ剰锛氭瘡娆″惎鍔ㄦ椂浼氭竻闄よ崏绋跨紦瀛橈紝鏄剧ず鍏ㄦ柊鐨勭┖鐧界紪杈戠晫闈€?

---

## 鍏€侀」鐩灦鏋?

```
lib/
鈹溾攢鈹€ main.dart                          # 搴旂敤鍏ュ彛
鈹溾攢鈹€ editor/                            # 缂栬緫鍣ㄧ粍浠?
鈹?  鈹溾攢鈹€ editor_screen.dart             # 缂栬緫鍣ㄤ富鐣岄潰
鈹?  鈹溾攢鈹€ editor_toolbar.dart            # 鏍煎紡鍖栧伐鍏锋爮
鈹?  鈹溾攢鈹€ editor_shortcuts.dart          # 蹇嵎閿鐞?
鈹?  鈹溾攢鈹€ highlighted_editor.dart        # 楂樹寒缂栬緫鍣?
鈹?  鈹溾攢鈹€ markdown_text_editor.dart      # Markdown 鏂囨湰缂栬緫
鈹?  鈹溾攢鈹€ markdown_editor_highlighter.dart # 缂栬緫鍣ㄨ娉曢珮浜?
鈹?  鈹溾攢鈹€ markdown_syntax_highlighter.dart # 璇硶楂樹寒瑙勫垯
鈹?  鈹溾攢鈹€ markdown_preview.dart          # 瀹炴椂棰勮
鈹?  鈹溾攢鈹€ document_outline.dart          # 鏂囨。澶х翰
鈹?  鈹溾攢鈹€ document_stats.dart            # 鏂囨。缁熻
鈹?  鈹溾攢鈹€ document_tab.dart              # 鍗曚釜鏍囩椤?
鈹?  鈹溾攢鈹€ document_tab_bar.dart          # 鏍囩鏍?
鈹?  鈹溾攢鈹€ find_replace_bar.dart          # 鏌ユ壘鏇挎崲鏍?
鈹?  鈹溾攢鈹€ insert_image_dialog.dart       # 鍥剧墖鎻掑叆瀵硅瘽妗?馃啎
鈹?  鈹斺攢鈹€ markdown_extensions/           # Markdown 鎵╁睍
鈹?      鈹溾攢鈹€ math_builder.dart          # 鏁板鍏紡鏋勫缓鍣?
鈹?      鈹溾攢鈹€ math_inline_syntax.dart    # 琛屽唴鍏紡璇硶
鈹?      鈹溾攢鈹€ math_block_syntax.dart     # 鍧楃骇鍏紡璇硶
鈹?      鈹溾攢鈹€ mermaid_builder.dart       # Mermaid 鍥捐〃鏋勫缓鍣?
鈹?      鈹斺攢鈹€ mermaid_syntax.dart        # Mermaid 璇硶
鈹溾攢鈹€ file_tree/                         # 鏂囦欢鏍?馃啎
鈹?  鈹溾攢鈹€ file_tree_node.dart            # 鏂囦欢鏍戣妭鐐?
鈹?  鈹斺攢鈹€ file_tree_panel.dart           # 鏂囦欢鏍戦潰鏉?
鈹溾攢鈹€ image_service/                     # 鍥剧墖鏈嶅姟 馃啎
鈹?  鈹溾攢鈹€ image_service.dart             # 鍥剧墖鏈嶅姟鍏ュ彛
鈹?  鈹斺攢鈹€ image_service_base.dart        # 鍥剧墖鏈嶅姟鍩虹被
鈹溾攢鈹€ table_editor/                      # 琛ㄦ牸缂栬緫鍣?馃啎
鈹?  鈹斺攢鈹€ table_editor.dart
鈹溾攢鈹€ task_list/                         # 浠诲姟鍒楄〃 馃啎
鈹?  鈹斺攢鈹€ task_list_editor.dart
鈹溾攢鈹€ file_service/                      # 鏂囦欢鎿嶄綔
鈹?  鈹溾攢鈹€ file_service.dart              # 鏂囦欢鏈嶅姟鍏ュ彛
鈹?  鈹溾攢鈹€ file_service_base.dart         # 鍩虹被
鈹?  鈹溾攢鈹€ file_service_io.dart           # 妗岄潰绔疄鐜?
鈹?  鈹溾攢鈹€ file_service_web.dart          # Web 绔疄鐜?
鈹?  鈹斺攢鈹€ file_service_stub.dart         # 瀛樻牴
鈹溾攢鈹€ recent_store/                      # 鏈€杩戞枃浠?
鈹?  鈹溾攢鈹€ recent_store.dart
鈹?  鈹溾攢鈹€ recent_store_base.dart
鈹?  鈹溾攢鈹€ recent_store_io.dart
鈹?  鈹溾攢鈹€ recent_store_web.dart
鈹?  鈹斺攢鈹€ recent_store_stub.dart
鈹溾攢鈹€ storage/                           # 鑽夌瀛樺偍
鈹?  鈹溾攢鈹€ document_store.dart
鈹?  鈹溾攢鈹€ document_store_base.dart
鈹?  鈹溾攢鈹€ document_store_io.dart
鈹?  鈹溾攢鈹€ document_store_web.dart
鈹?  鈹斺攢鈹€ document_store_stub.dart
鈹溾攢鈹€ settings/                          # 璁剧疆
鈹?  鈹溾攢鈹€ settings.dart
鈹?  鈹溾攢鈹€ settings_base.dart
鈹?  鈹溾攢鈹€ settings_io.dart
鈹?  鈹溾攢鈹€ settings_web.dart
鈹?  鈹溾攢鈹€ settings_stub.dart
鈹?  鈹斺攢鈹€ settings_panel.dart
鈹溾攢鈹€ export/                            # 瀵煎嚭
鈹?  鈹溾攢鈹€ export_service.dart            # 瀵煎嚭鏈嶅姟
鈹?  鈹溾攢鈹€ export_options_dialog.dart     # 瀵煎嚭閫夐」瀵硅瘽妗?
鈹?  鈹斺攢鈹€ css_templates.dart             # 12 绉?CSS 妯℃澘
鈹溾攢鈹€ cloud_sync/                        # 浜戝悓姝?
鈹?  鈹溾攢鈹€ cloud_sync.dart                # 鍚屾鍏ュ彛
鈹?  鈹溾攢鈹€ cloud_sync_service.dart        # 鍚屾鏈嶅姟
鈹?  鈹溾攢鈹€ webdav_client.dart             # WebDAV 瀹㈡埛绔?
鈹?  鈹溾攢鈹€ local_backup.dart              # 鏈湴澶囦唤
鈹?  鈹溾攢鈹€ sync_config.dart               # 鍚屾閰嶇疆
鈹?  鈹溾攢鈹€ sync_settings_panel.dart       # 鍚屾璁剧疆闈㈡澘
鈹?  鈹斺攢鈹€ sync_status.dart               # 鍚屾鐘舵€?
鈹溾攢鈹€ spell_check/                       # 鎷煎啓妫€鏌?
鈹?  鈹溾攢鈹€ spell_checker.dart             # 鎷煎啓妫€鏌ュ櫒
鈹?  鈹斺攢鈹€ spell_check_overlay.dart       # 鎷煎啓妫€鏌ヨ鐩栧眰
鈹溾攢鈹€ custom_theme/                      # 鑷畾涔変富棰?
鈹?  鈹溾攢鈹€ custom_theme.dart              # 涓婚鍏ュ彛
鈹?  鈹斺攢鈹€ theme_picker.dart              # 涓婚閫夋嫨鍣?
鈹斺攢鈹€ templates/                         # 鏂囨。妯℃澘
    鈹斺攢鈹€ document_templates.dart
```

璺ㄥ钩鍙板疄鐜伴噰鐢ㄦ潯浠跺鍑猴紙`dart.library.io` / `dart.library.html`锛夛紝妗岄潰绔拰 Web 绔悇鑷疄鐜板钩鍙扮壒瀹氬姛鑳姐€?

---

## 涓冦€佷緷璧栬鏄?

| 鍖呭悕 | 鐢ㄩ€?|
|------|------|
| `flutter_markdown_plus` | Markdown 棰勮锛圙FM 鏀寔锛?|
| `markdown` | Markdown 鈫?HTML 杞崲锛堝鍑虹敤锛?|
| `file_picker` | 鍘熺敓鏂囦欢閫夋嫨瀵硅瘽妗?|
| `pdf` + `printing` | PDF 鐢熸垚涓庡垎浜?|
| `desktop_drop` | 鏂囦欢鎷栨嫿鎵撳紑 |
| `webview_flutter` | WebView 缁勪欢 |
| `http` | HTTP 缃戠粶璇锋眰 |
| `crypto` | 鍔犲瘑鍝堝笇锛堝悓姝ユ牎楠岋級 |

---

## 鍏€佸紑鍙戜笌楠岃瘉

### 浠ｇ爜妫€鏌?
```bash
dart format lib test
flutter analyze
flutter test
```

### CI/CD
椤圭洰宸查厤缃?GitHub Actions锛屾敮鎸佷笁骞冲彴鑷姩鏋勫缓锛?
- `build-windows`锛歐indows Release 鏋勫缓
- `build-linux`锛歀inux Release 鏋勫缓锛圲buntu latest锛?
- `build-macos`锛歮acOS Release 鏋勫缓锛坢acOS latest锛?

姣忔鎺ㄩ€佸埌 `main` 鍒嗘敮鑷姩瑙﹀彂鏋勫缓锛屼骇鐗╀笂浼犺嚦 Artifacts銆?

---

## 涔濄€佸凡鐭ラ檺鍒?

1. 鏁板鍏紡鍜?Mermaid 鍥捐〃鐨勫疄鏃堕瑙堥渶瑕佺綉缁滆繛鎺ワ紙鍔犺浇 CDN 璧勬簮锛?
2. 鎷煎啓妫€鏌ヤ粎鏀寔鑻辨枃锛屼娇鐢ㄥ唴缃瘝搴擄紝鍑嗙‘搴︽湁闄?
3. Web 绔繚瀛樻枃浠朵細瑙﹀彂娴忚鍣ㄤ笅杞斤紝鑰岄潪鐩存帴鍐欏叆纾佺洏
4. PDF 瀵煎嚭鐨勪腑鏂囨帓鐗堝彈 SimHei 瀛椾綋闄愬埗

---

## 鍗併€佹洿鏂版棩蹇?

### v1.0.1 (2026-06-17)

**Bug 淇锛?*
- 淇澶氭爣绛鹃〉 ID 閲嶅瀵艰嚧鏍囩鍒囨崲/鍏抽棴寮傚父
- 淇 WebDAV URL 鏋勯€犻敊璇鑷翠簯鍚屾涓嶅彲鐢?
- 淇鏈湴澶囦唤璺緞纭紪鐮佸鑷村浠?鎭㈠澶辫触
- 淇鍥剧墖鎻掑叆鍚庣敓鎴愮┖ markdown 璇硶
- 淇鐘舵€佹爮涓嶆樉绀鸿鍙?鍒楀彿/璇嶆暟/瀛楃鏁?
- 淇浜戝悓姝ユ湇鍔″垵濮嬪寲涓嶅垱寤哄鎴风銆佽嚜鍔ㄥ悓姝ョ┖鍥炶皟
- 淇閿欒娑堟伅涓㈠純寮傚父璇︽儏
- 淇 `_formatTime` 杩斿洖鎹熷潖瀛楃涓?
- 淇璁剧疆闈㈡澘涓嶆樉绀哄瓧浣撳ぇ灏忓拰鑷姩淇濆瓨闂撮殧鏁板€?
- 淇浠ｇ爜鐗囨妯℃澘涓暟瀛﹀叕寮?Mermaid 璇硶杞箟閿欒

**鍔熻兘鏀硅繘锛?*
- PDF 瀵煎嚭鏂板浠ｇ爜鍧楁覆鏌撳拰琛ㄦ牸瑙ｆ瀽鏀寔
- 鎵撳紑鏂囦欢鍚庤嚜鍔ㄤ繚瀛樼幇鍦ㄦ甯稿惎鍔?
- 宸ュ叿鏍忔柊澧炰唬鐮佺墖娈垫寜閽紙鍒嗗壊绾裤€佺洰褰曘€佽〃鏍兼ā鏉裤€佷换鍔″垪琛ㄣ€佽剼娉ㄣ€佸叕寮忋€丮ermaid锛?
- 鍥剧墖鎻掑叆鏀寔 URL 杈撳叆鍜屾浛浠ｆ枃鏈?
- 淇 SpellCheckOverlay 甯冨眬绾︽潫
- 淇 Mermaid 鏋勫缓鍣ㄨ儗鏅壊/鏂囧瓧鑹?鍥捐〃鍐呭娉ㄥ叆
- 娓呯悊 11 涓┖鏃ュ織鍜屼复鏃舵枃浠?

**浠ｇ爜璐ㄩ噺锛?*
- `flutter analyze`: 0 issues
- `flutter test`: 24/24 閫氳繃
- 绉婚櫎鏈娇鐢ㄧ殑鏂规硶鍜屽鍏?

### v1.0.0 (2026-06-16)

- 鍒濆鍙戝竷
- 鏀寔 Windows 鍜?Web 骞冲彴

---

## 鍗佷竴銆佸悗缁鍒?

- [ ] 鏇村 CSS 瀵煎嚭妯℃澘
- [ ] 澶ф枃浠舵€ц兘浼樺寲锛堣櫄鎷熸粴鍔級
- [ ] 绉诲姩绔€傞厤
- [ ] 涓枃鎷煎啓妫€鏌?
- [ ] 鍗忎綔缂栬緫
- [ ] Vim/Emacs 閿綅妯″紡
- [ ] 鑷畾涔夊揩鎹烽敭缁戝畾
- [ ] 鎻掍欢绯荤粺

---

*鏈枃妗ｇ敱 QClaw 鑷姩鐢熸垚锛屽熀浜庨」鐩簮鐮佸垎鏋愩€?
