# Yoshida Medium
Yoshida's stock solution for root architecture media rice

## Macro-stock
| 800x Macro stock                                                          | Grams / L | Location  |
| :-------                                                                  | :-------: | :-----:   |
| NH<sub>4</sub>NO<sub>3</sub>                                              | 91.4      |   VIII    |
| CaCl<sub>2</sub>                                                          | 88.6      |    IV     |
| NaH<sub>2</sub>PO<sub>4</sub> &bullet; 2H<sub>2</sub>O <sup>&#8251;</sup> | 40.3      |   VIII    |
| K<sub>2</sub>SO<sub>4</sub> <sup>&sect;</sup>                             | 71.4      |   VIII    |
| MgSO<sub>4</sub> &bullet; 7H<sub>2</sub>O <sup>&sect;</sup>               | 324       |   VIII    |

<sup>&#8251;</sup> 若使用 **NaH<sub>2</sub>PO<sub>4</sub> &bullet; H<sub>2</sub>O**, 則需 **17.8** g / L;  
<sup>&sect;</sup> K<sub>2</sub>SO<sub>4</sub> 和 MgSO<sub>4</sub> &bullet; 7H<sub>2</sub>O 較易發霉，需冷藏; 

<br>

## Micro-stock
| 800x Micro stock                                                                            | Grams / L | Location |
| :-------                                                                                    | :-------: | :------: |
| MnCl<sub>2</sub> &bullet; 4H<sub>2</sub>O                                                   |    1.5    |   VIII   |
| (NH<sub>4</sub>)<sub>6</sub> &bullet; MO<sub>7</sub>O<sub>24</sub> &bullet; 4H<sub>2</sub>O |   0.074   |   VIII   |
| H<sub>3</sub>BO<sub>3</sub>                                                                 |   0.934   |   VIII   |
| ZnSO<sub>4</sub> &bullet; 7H<sub>2</sub>O                                                   |   0.035   |   VIII   |
| CuSO<sub>4</sub> &bullet; 5H<sub>2</sub>O                                                   |   0.031   |   VIII   |
| FeCl<sub>3</sub> &bullet; 6H<sub>2</sub>O                                                   |    7.7    |   VIII   |
| Citric acid (monohydrate)                                                                   |   11.9    |   VIII   |

<hr>

## Diluted Yoshida medium ( pH 5.8 )
|                                                           |    1L    | 2L  | 4L  | 存放位置 |
|   :---------                                              |    :---:   | :---: | :---: | :--: |
| 800x Macro stock (mL)                               
| NH<sub>4</sub>NO<sub>3</sub>                              |   1.25   | 2.5 | 5 |
| NaH<sub>2</sub>PO<sub>4</sub> &bullet; H<sub>2</sub>O     |   1.25   | 2.5 | 5 |
| K2SO4                                                     |   1.25   | 2.5 | 5 |
| CaCl2                                                     |   1.25   | 2.5 | 5 |
| MgSO4 &bullet; 7H<sub>2</sub>O                            |   1.25   | 2.5 | 5 |
| 800x Micro stock (mL)                                     |   1.25   | 2.5 | 5 |
| MES hydrate (g)                                           |   0.546  | 1.092 | 2.184 | III |

\* 補水定量至目標公升數  
\* 初始 pH 值大約為 pH 2.6，加 5 顆 **NaOH** 後大約會提高至 pH 5.2, 
爾後以 5N NaOH （放在七號櫃）逐漸滴定至 pH 5.8。
以液面完全靜止時的數值為準，因旋轉時 pH 值會下降。
例如, 在 300 rpm 下, pH 值約為 5.764; 0 rpm ( 停止旋轉 ) 時則約為 5.807

<hr>

## pH 校正
1. 以 ddH2O 潤洗後拭鏡紙擦乾，插入 pH 4 (粉紅色) 的校正液中；
2. 待數值穩定後，按 `edit` 改成 pH 4 ，再按 `accept`;
3. 按 `next`
4. 潤洗乾淨，擦乾，插入 pH 7 的校正液中；
5. 重複上述 2-4 步驟；
6. 校正結束後按 `call done`。

| pH    | mV <sup>&dagger;</sup>        | Slope    |
| :---: | :---------:                   | :------: |
| 4     | 176 &pm; 30 ( 146 to 206 )    | > 90%    |
| 7     | 0 &pm; 30 ( -30 to 30 )       | > 90%    |
| 10    | -176 &pm; 30 ( -206 to -146 ) | > 90%    |

<sup>&dagger;</sup> Standard value of mV at 25&deg;C among different pH.


### 配製 pH 校正溶液 ( NaOH & HCl )
$$ M = \frac{mol}{L} = \frac{\frac{g}{mol.weight}}{L} $$
$$ N = M \times 解離常數 $$
