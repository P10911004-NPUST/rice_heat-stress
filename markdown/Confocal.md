---
output:
  html_document:
    theme: 
      version: 4
---

# Confocal laser scanning microscope

### 打開 防塵套

### 打開 顯微鏡系統 ( 打開順序：從 1 到 4 )

> -   1 和 2 號：在桌底下，順時鐘打開\
> -   3 號：在桌上，是一個儀器的開關鍵\
> -   4 號：在上方，是電腦開關

### 啟動 電腦軟件 (Zen)

Zen → Zen system → 等待左側菜單載入完成 ( 大約 30 秒 )

### 檢查 物鏡倍率

開始操作前，確認目前是 5 倍鏡 ( 左手邊的 monitor, 進入 <b style='color:darkgrey'>Microscope</b> 可查看)

> -   若 monitor 熒幕出現 "lower Z limit" 訊息，這表示載物台已處於最低位置。 
執行其他操作前，先把載物台略微上調 ( 載物台滾輪 順時鐘 旋轉 ), 該訊息會自動消失, monitor 才可正常操作。

### 放入 樣本玻片

1.  按 <b style='color:red'>Load position</b> ( 在 monitor 上 );
2.  輕緩推開顯微鏡的頭部，註意手不要碰觸到上面的轉輪;
3.  由於光源是由下往上，因此玻片需朝下 ( 必須確保蓋玻片牢固地被固定在玻片上，絕對不能掉下來 );
4.  把玻片卡入載物台 (先把玻片卡入一側的卡槽，再移動另一側的卡槽);
5.  把顯微鏡頭部拉回來。

### 初步 對焦

1.  電腦上先選擇 <b style='color:orange'>Locate</b> 巨集，切換至 BF 或 DIC 視野;
2.  使用搖桿尋找樣本目標區域;
3.  使用顯微鏡本體的轉輪或 monitor 的轉輪進行初步對焦。

> - 逆時針 : 載物台往上, 玻片遠離鐳射鏡頭 \
順時針 : 載物台往下, 玻片靠近鐳射鏡頭

### 熒光參數

1.  進入 <b style='color:orange'>Acquisition</b> 巨集;
2.  在 <b style='color:darkgrey'>Experiment</b> 裡選擇欲使用之波長組合 ( 例如 405 + 488 + 561 );
3.  等待 laser 預熱 (直到各波長之紅色背景消失);
4.  勾選欲打開之波長 ( 例如 488 nm 和 561 nm );
5.  點選主要波長，<b style='color:violet'>Pinhole</b> 設置為 1 A.U. ( 每批次只需設置一次 );
6.  點選主要波長並勾選 T-PMT (白光)，此為同步白光和主要熒光的鐳射強度;
7.  設置主波長的 <b style='color:violet'>Laser intensity</b> 和 <b style='color:violet'>Master gain</b> 參數 ( 逐次按 Snap 觀察 );

> -   Laser intensity : 激發更多熒光蛋白，但鐳射過強容易破壞蛋白;\
> -   Master gain : 光電倍增，提高對熒光的 sensitivity, 但會同時增加 signal 和 noise。Gain 值太高也會使邊緣模糊。

8.  次要波長無需再設置 Laser intensity, 調整 Master gain 即可 ( Laser intensity 會和主波長同步 );
9.  微調焦距 ( 使用 Continuous 模式，調好後記得再次點 Continuous 取消連拍模式，以免長時間鐳射過度破壞蛋白 );
10. 勾選 Range indicator 檢查各波段是否過曝，再微調鐳射參數;

> -   藍色 : signal 較弱
> -   紅色 : 過曝，應降低 Laser intensity 或 Master gain

### Z-stack

1.  勾選 Z-stack;
2.  進入 Continuous 模式，調整焦距，設定 First 和 Last layer; 以接近熒光最強的圖層焦距作為 First layer, 再接著往下設定 Last layer; 以能夠涵蓋所有欲觀察之對象為目標;
3.  First 和 Last layer 設定好後，直接採用 optimal range 即可;

> -   Optimal range 為 Pinhole 的一半，意即每一層掃描都會有 50% 與上一層重疊;

4.  選取中間層 ( 縮寫為 "C" ) 微調參數並檢查是否過曝；這一層應該為亮度最高;
5.  調整 Resolution: <b style='color:violet'>Frame size → Preset</b> ( 至少 1024 × 1024 );
6.  ( Optional ) 也可調整 Scan speed ( 數值越低, 清晰度越高, 6 或 7 較為理想 );
7.  按 Start experiment 開始掃描。

### Image processing

1.  進入 <b style='color:orange'>Processing</b> 巨集;
2.  Method 選擇 Orthogonal projection;
3.  Parameter 裡選擇欲用以進行 stacking 的圖層範圍;
4.  Thickness 參數為從第一層到第幾層要做 stacking;
5.  設定完成後，點選 Apply 即可產生 stacked layer。

### Oil lens

> -   已上油的玻片置入載物台後，不可再切換鏡頭 ( 因鏡頭模組旋轉將使油滴飛濺，並且其他鏡頭也將沾上油滴 );
> -   油鏡是滴在玻片上，水鏡才是滴在鏡頭上。

1.  先以<b style='color:darkgray'>低倍率</b>找到樣本並且對好焦距;
2.  先切換鏡頭到油鏡倍率 ( exp. 63X oil ), 彈出視窗先不理會，然後再卸下玻片滴油;

> -   拿起玻片前，確認目前在 Acquisition 巨集 ( 若在 Locate 巨集，則點選遮罩鐳射光源 )，避免鐳射直接照射眼睛

3.  拿起玻片，在玻片上滴一小滴油，再放回載物台 (滴油那一面同樣朝下);
4.  點 Done ( 不可點 Back )，此時鐳射鏡頭自動往上貼近玻片並沾上油; 要確認鐳射鏡頭和玻片有沾上油;
5.  先用目鏡找樣本並對焦; 

> - 若一直都找不到樣本，可能視野已偏移，又或者焦距已大幅改變。
若是視野偏移, 可用 DIC 模式 ( 在 Locate 巨集裡設定 ) 並降低入光量, 比較容易看到樣本；
若是焦距問題, 可先點選 monitor 上的 XYZ 選項檢查 Z-position, 若 Z-position 數值已超過 2, 
表示鐳射鏡頭很可能快要撞到玻片, 建議調焦距時轉輪先往前輕緩旋轉 ( 鏡頭遠離玻片 ) 開始找焦距較為妥當。

6.  切換至波長以目鏡觀察, 理想狀況是目鏡即可看到熒光;
7.  回到 Acquisition 巨集，使用主波長，調整焦距;
8.  後續步驟和一般流程一樣;
9.  換玻片必須點 Load position;
10.  使用完油鏡後，按 Load position, 卸下玻片, 以 Lens paper 和 100% 酒精, 輕緩擦拭油鏡鏡頭;

> -   大約 三次 單一方向 輕抹即可把油擦除;

10. 再以新的 Lens paper 把該鏡頭擦乾。

### Water lens

操作與油鏡一樣, 唯一差別為, 透光介質為 XXX-W 且直接滴在 43X 的鏡頭上。

### Miscellaneous
選取照片後, 點選 reuse (Snap 按鍵上方) 即可直接套用該照片之設定。
