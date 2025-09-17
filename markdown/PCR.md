---
output:
  html_document:
    theme: 
      version: 4
---

# Polymerase Chain Reaction (PCR)

## Preparation  

| Material <sup>&#8251;</sup>                  | Quantity per sample | Note                                                        |
| :---:                     | :---:               | :---:                                                       |
| gDNA <sup>&dagger;</sup>  | 40 ng               | Store at -20&deg;C                                          |
| F (forward-primer)        | 0.4 &micro;L        | Located at -20&deg;C (2row-3col-4layer; primer-box E1 & 2)  |
| R (reverse-primer)        | 0.4 &micro;L        | Located at -20&deg;C (2row-3col-4layer; primer-box E1 & 2)  |
| 2X-Taq                    | 5 &micro;L          | Located at -20&deg;C (4row-3col-4layer; orange lid)         |
|                           |                     |                                                             |
| Total :                   | 10 &micro;L         |                                                             |

<sup>&#8251;</sup> All materials should be placed on ice.

<sup>&dagger;</sup> gDNA : The gDNA stock solution of all samples should be standardized to 
the same concentration, for example 10 ng/&micro;L.

## Procedure:
1. Prepare the total amount of the required working solution ( F-primer, R-primer, 2X-Taq );

> - For example, if we had 10 samples, then me make the working solution by adding 
> 4 &micro;L <b style="color:orange">F-primer</b>, 
> 4 &micro;L <b style="color:orange">R-primer</b>, 
> and 50 &micro;L <b style="color:orange">2X-Taq</b> into a new 200 &micro;L PCR tube.

2. Portioning the working solution into the new 200&micro;L PCR tubes ( 5.8 &micro;L for each sample );
3. Lastly, add the sample gDNA stock solution;
4. Close the lid tightly, and swipe the tube gently with finger several time to mix the solution well;
5. Slightly centrifuge to bring down the solution;
6. Put into the PCR machine (the machine should be warmed-up around 30 secs before usage).

## Reaction curve:
| Temperature (&deg;C) | Time       | Cycle | Note                 |
| :--:                 | :--:       | :--:  | :-----:              |
| 95                   | 1 min      | --    | Initial denaturation |
| 95                   | 15 secs    | 30    | Denaturation         |
| 56                   | 15 secs    | 30    | Annealing            |
| 72                   | 1 min      | 30    | Extension            |
| 72                   | 5 min      | --    | Complete extension   |
| 4                    | &#8734;   | --    | PCR product storage  |

