---
output:
  html_document:
    theme: 
      version: 4
---

# DNA extraction (fast method)
- take less time, but low concentration of DNA

## Preparation:
| Material                              | Quantity per sample | Note                                                |
| :---:                                 | :---:               | :---:                                               |
| Extraction buffer <sup>&dagger;</sup> | 400 &micro;L        |                                                     |
| Isopropanol (2-propanol)              | 300 &micro;L        | Around 70% of the supernatant taken from the buffer |
| Ethanol (EtOH)                        | 1000 &micro;L       | Use DNase-free ethanol and ddH<sub>2</sub>O         |
| Tris-EDTA                             | 100 &micro;L        | Commercial product                                  |


### <sup>&dagger;</sup> Extraction buffer
> 200 mM Tris-HCl (pH 7.5)  
> 250 mM NaCl  
> 25 mM EDTA  
> 0.5% SDS  

| Extraction buffer stock solution            | Addition |
| :---:                                       | :---:    |
| 1 M Tris-HCl (pH 7.5) <sup>&#8251;</sup>    | 20 mL    |
| 5 M NaCl                                    | 5 mL     |
| 500 mM EDTA <sup>&dagger;</sup>             | 5 mL     |
| 10% SDS <sup>&sect;</sup>                   | 5 mL     |
| ddH<sub>2</sub>O                            | 65 mL    |
|||
| Total:                                      | 100 mL   |


## Procedure:
1. Cut 5-10 pieces of root tissues, powderized them after frozen with liquid nitrogen;

> Caution: if directly powderized within ependorf, after fill in liquid nitrogen into the tube, 
DO NOT close the lid, the eppendorf will exploded.

2. Add <b>400 &micro;L</b> of the <b style="color:orange">extraction buffer</b>, 
gently inverting the tube to mix the buffer;
3. Slightly <b style="color:orange">centrifuge</b> to bring down all the mixtures to the bottom of the eppendorf. 
If there are many samples, they should be placed on ice;
4. Place on <b style="color:orange">benchtop</b> at <b>room temperature</b> for <b>1 hour</b>;
5. <b style="color:orange">Centrifuge</b> at <b>15000 rpm</b> for <b>15 minutes</b> 
at room temperature to bring down the tissue residues;
6. <b>Transfer the supernatant</b> (~ 300&micro;L) to a new tube;
7. Add 210 &micro;L isopropanol to <b>precipitate the DNA</b>. 
The volume of isopropanol should be around 0.7 volume of the supernatant; 
Gently mix the isopropanol with the supernatant;
8. Keep the mixture at 4&deg;C for 24 hours or -20&deg;C for 2 hours to facillitate DNA precipitation;
9. <b>Centrifuge</b> at 15000 rpm for 15 minutes at room temperature to <b>bring down the DNA</b>; 
Pay attention to the eppendorf position, the DNA palette should be skewed on one side of the tube bottom;
10. <b>Discard the supernatant</b>; Carefully absorb the supernatant by not touching or too close to the DNA palette;
11. <b>Wash the DNA palette</b> by rinsing with 70% EtOH for 3 times (the volume same as the isopropanol); 
DO NOT invert or pipetting; the DNA palette should be always sticking on the tube bottom; 
<b>Centrifuge</b> at 15000 rpm for 10 minutes at 4&deg;C for each rinse, to make sure the DNA palette didn't float up;
12. <b>Dry the DNA</b> by putting the eppendorf in the dry incubator and set the temperature at 60&deg;C. 
the lid of the eppendorf should be opened to let the DNA dry;
13. Add 100 &micro;L Tris-EDTA to <b>dissolve the DNA</b>, 
put in the dry incubator at 60&deg;C to accelerate the dissolution. 
The lid of the eppendorf should be closed to avoid evaporation;
14. After dissolve, <b>measure the DNA quantity and quality</b>; 
the NanoDrop&trade; only requires 1 &micro;L of the DNA solution. 
Slightly centrifuge the DNA solution to make sure all water / solution on the eppendorf wall 
is fully bring down to the bottom, otherwise the DNA concentration would be not accurate;
15. Store the DNA solution in -20&deg;C.


## Quality assurance:
Reference: https://ntuhmc.ntuh.gov.tw/epaper-57th.htm

### Wavelength detection
| Wavelength (nm) | Detected Compound |
| :---: | :--- |
| 230 | EtOH, EDTA, carbohydrates, phenol, Guanidone HCL (for DNA isolation) |
| 260 | RNA,ssDNA, dsDNA, guanidine isothiocyabate (for RNA isolation) |
| 270 | Phenolic solution (TRIzol for RNA isolation) |
| 280 | Protein, phenol, other contamination |

### Ideal wavelength ratio (quality indicator):
| Nucleic acid | 260 / 280 | 260 / 230 | 260 / 270 |
| :---:        | :---:     | :---:     | :---:     |
| DNA          | ~ 1.8     | > 2.0     | > 1.2     |
| RNA          | ~ 2.0     | > 2.0     | > 1.2     |


## Stock solution protocol:

### <sup>&#8251;</sup> Tris-HCl stock solution ( 1 M )

To prepare a 1 M solution of Tris-HCl,

1. Dissolve 121.1 g of Tris base in 800 mL of ddH<sub>2</sub>O;
2. Adjust the pH to the desired value by adding concentrated HCl;
3. Allow the solution to cool to room temperature before making final adjustments to the pH;
4. Adjust the volume of the solution to 1 L with ddH<sub>2</sub>O. Dispense into aliquots and sterilize by autoclaving.

| pH    | 12N HCl addition |
| :---: | :---:            |
| 7.4   | 70 mL            |
| 7.6   | 60 mL            |
| 8.0   | 42 mL            |

### <sup>&dagger;</sup> EDTA stock solution 

> EDTA ( Ethylenediamenetetraacetic acid )

To prepare EDTA at 0.5 M (pH 8.0), 

1. Add 186.1 g of disodium EDTA &bullet; 2H<sub>2</sub>O to 800 mL of ddH<sub>2</sub>O;
2. Stir vigorously on a magnetic stirrer to dissolve the EDTA;
3. Adjust the pH to 8.0 with NaOH (~ 20 g of NaOH pellets);

> Note: The disodium salt of EDTA will not go into solution until the pH is adjusted to ~ 8.0 by the addition of NaOH.

4. Dispense into aliquots and sterilize by autoclaving.

### <sup>&sect;</sup> SDS stock solution ( 10% )

> Sodium dodecyl sulfate, sodium lauryl sulfate

To prepare a 10% (w/v) solution,

1. Dissolve 100 g of electropheresis-grade SDS in 900 mL of ddH<sub>2</sub>O;
2. Heat to 68&deg;C and stir with a magnetic stirrer to assist dissolution.
If necessary, adjust the pH to 7.2 by adding a few drops of concentrated HCl;
3. Adjust the volume to 1 L with ddH<sub>2</sub>O;
4. Store at room temperature. Sterilization is not necessary. 
<b style='color:red'>DO NOT</b> autoclave.


