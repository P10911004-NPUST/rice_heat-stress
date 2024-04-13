# NBT staining

## 配製 NBT 溶液
> 10 mM sodium phosphate buffer (pH 7.8)  
10 mM NaN<sub>3</sub>  
1 mg mL<sup>-1</sup> NBT powder

每個樣本大約需要 0.5 ml NBT 溶液浸泡。  
例如，假設有 20 個樣本 (需要 10 ml 溶液)，則取 **1 ml 的 100 mM sodium phosphate buffer 母液**、**1 ml 的 100 mM NaN<sub>3</sub>**，和 **10 mg NBT 粉末**；然後以 **ddH<sub>2</sub>O 定量至 10 ml**。

1. 先配好溶液 (sodium phosphate buffer + NaN<sub>3</sub> + ddH<sub>2</sub>O) 在大離心管內；
2. NBT 粉末放在 7 號櫃，棕色小瓶。可以用小離心管小量盛裝並以精密天平稱重。小藥匙在精密天平下方的抽屜裡；
3. 稱好 NBT 粉末後，用溶液注入小離心管內和 NBT 粉末混合；
4. 用 Vortex 震蕩使 NBT 粉末充分混合；
5. 逐次以小量大離心管的溶液與小離心管內的混合液交換稀釋，使 NBT 充分溶解。
6. 最終得到淡黃色的 NBT 溶液在大離心管內；
7. 以鋁箔紙包覆大離心管，避免光照；
8. 條件允許，可先將 NBT 溶液預熱至 37&deg;C。

## 拍照記錄
1. 裝一盤水，底下放黑色紙皮，旁邊放一把尺，準備好相機；
2. 每個小離心管裝好 0.5 ml 的 NBT 溶液；
3. 取出植株，每次約 6 株，放到盤裡，對齊胚乳位置；
4. 拍照時以另一大片的黑色紙皮擋在上方 (可用相機撐住)，避免水面光斑；
5. 拍照前先放大調好焦距，然後拍照；
6. 拍完即可剪取根尖，約 1 cm；
7. 以長尖鑷輕輕夾取遠離根尖的部位，放入小離心管內，完全浸泡根尖；
8. 置於 dry bath incubator 37&deg;C 加熱 30 mins (鋁箔盒子蓋住遮光)。

## 顯微鏡拍照 (NBT staining 加熱 30 mins 後)
1. 先開顯微鏡系統電源，開光源，熱機；
2. 開電腦，開軟體 LAS X；
> Exposure time [ms] --> 300  
Gain --> 2.0  
Magn. Camera --> 16x (顯微鏡左手邊倍數轉到 1.6)
3. 玻片加點水；
4. 小心夾取根尖，整齊置放於玻片上，蓋上；
5. 可按 Live 同步電腦熒幕和目鏡視野，微調焦距盡量使根細胞清晰；
6. 按下 Single Image 拍照；
7. 在 Open Projects 欄目下可更改已儲影像的名稱
8. 使用 Public 之 NAS 傳輸檔案，不可使用 USB；
9. 完成後關電腦、光源，以及系統；記得蓋回防塵袋。

## ImageJ 處理影像
Connect to the Public server (10.20.36.49) 

### 測量根長 
1. 拉直線；  
2. Set scale (**Known distance:** 1, **Unit of length:** mm, **Pixel aspect ratio:** 1);
3. 拉曲線 (freehand line) 測量 seminal root (長按直線圖標右下角的三角圖標即會顯示 freehand 選項)；

### NBT staining 顯微鏡影像
1. 影像轉成 8-bit；
2. Invertion （背景為黑色）
3. Polygon selection  
4. $ \text{NBT intensity} = Area \ast Mean $