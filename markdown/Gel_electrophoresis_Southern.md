---
output:
  html_document:
    theme: 
      version: 4
---

# Gel electrophoresis (Southern)

## Preparation
| Material                                         | Concentration  | Final concentration | Location         |
| :-------:                                        | :-----:        | :---:               | :----------:     |
| PCR product                                      | 10 ng/&micro;L | --                  | Store at 4&deg;C |
| TAE buffer <sup>&#8251;</sup>                    | 50X            | 0.5X                | II               |
| Agarose gel <sup>&dagger;</sup>                  | --             | 3%                  | II               |
| SYBR<sup>&reg;</sup> stock solution <sup>*</sup> | 1000X          | 1X                  | II               |
| Loading Dye                                      | 6X             | 1X                  | 4&deg;C (c)      |
| RTU-100 (Ladder marker)                          | --             | --                  | 4&deg;C (c)      |

<sup>&#8251;</sup> Each run requires at least 500 mL 0.5X TAE buffer;

<sup>&dagger;</sup> For the big gel slot, requires around 40 mL gel (the small slot requires 20 mL). 
Therefore, add 1.2 g agarose powder (ultra pure grade) to 40 mL 0.5X TAE buffer.

<sup>*</sup> To prepare 1000X SYBR stock solution, 
dilutes 100 &micro;L SYBR<sup>&reg;</sup> raw solution with 900 &micro;L DMSO.

## Procedure:
1. Prepare the gel. After adding agarose powder into the 0.5X TAE buffer, melt them with microwave.
> - using mid-low firepower, 1 mins &rarr; 30 secs &rarr; add ddH<sub>2</sub>O &rarr; 20 secs &rarr; 10 secs

2. Add 0.001 volume of SYBR stock solution into the gel solution immediately, gently shake to mix them well;
> - For example, 40 mL gel requires 4 &micro;L 1000X SYBR stock solution.
3. Pour the gel into the gel container and wait for solidification (around 15 mins);
4. Prepare the electropheresis machine, the electrode direction should be from negative to positive;
5. After the gel was solidified, put the gel container together with the gel into the elctrophoresis machine;
6. Add some TAE buffer (same strength with the gel; 0.5X in this case) into the electropheresis machine 
and make sure the gel was fully submerged in the buffer;
7. Add loading dye to the PCR product. The loading dye final concentration should be 1X.
For example, 2 &micro;L 6X loading dye + 10 &micro;L PCR product;
8. Smoothly inject 2 &micro;L ladder marker into the first and last wells of the gel;
9. Smoothly inject the blank and PCR product;
10. Set the voltage as 135 V and the runtime as 40 mins;
> <b>5 ~ 10 V / cm</b> for DNA size < 1 kb;  
> 4 ~ 10 V / cm for DNA size between 1 ~ 12 kb;  
> 1 ~ 3 V / cm for DNA size greater than 12 kb.<br>
> <i>Note: For our machine, the distance between the electrodes is around 13.5 cm.</i>

## Gel-imaging
1. Open machine (Bio-Rad Gel Doc XR+);
2. Put in the gel;
3. Start up the "Image Lab" software;
4. New protocol
5. Gel imaging
6. Application &rarr; Select &rarr; Nucleic acid &rarr; SYBR<sup>&reg;</sup> Safe
7. Position Gel &rarr; Filter 1 &rarr; adjust gel position
8. Run protocol
9. Export for publication