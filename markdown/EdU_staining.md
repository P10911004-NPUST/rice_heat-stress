---
output:
  html_document:
    theme:
      version: 4
  pdf_document: default
---

# **EdU staining**

### <a href="https://www.thermofisher.com/order/catalog/product/tw/en/C10351">Invitrogen&trade; Click-iT&trade; EdU Alexa Fluor&trade; 488 HCS Assay</a>

> 5-Ethynyl-2'-deoxyuridine  
> 252.22 g/mol

- "**ddH<sub>2</sub>O**" means deionized water;
- "**complete medium**" means the medium used to cultivate the samples. for example, half-MS medium.

<br>

# Experimental Procedure

## Step 1: Labeling

1. Prepare <b style='color: violet'>incubation medium</b> containing <b style='color: violet'>10 &micro;M Component A</b>;
- For example, in 5 samples scenario, add 100 &micro;L Component A ( 10 mM ) into 100 mL half-MS medium for the experiment. Then, repackage the diluted Component A to new falcon tubes, each tube takes around 20 mL for each sample ( make sure the root tips can be fully submerged into the solution).
2. Incubate the plants in the <b style='color: violet'>incubation medium</b> in the same cultivation condition for <b style='color: violet'>1 ~ 2 hours</b>.
- Directly immersed the roots in the solution, <b style='color: red'>DO NOT</b> cut the shoot part, the plant should still alive. The root should be fully submerged into the solution. Do not over-pushing the root to avoid roots injury. 

## Step 2: Fixation

1. Cut the root tip and immerse in 200 &micro;L <b style='color: violet'>fixative solution</b> in eppendorf;

2. Incubate for <b style='color: violet'>30 minutes</b> under <b style='color: violet'>room temperature</b>;

3. Remove fixative solution and add 400 &micro;L of <b style='color: violet'>1X PBS</b> to wash the roots. Repeat this wash  procedure three times, for each 10 mins ( <b style='color: violet'>3 &times; 10 mins</b> ).
- <b style='color: darkorange'>You can safely store the samples in 1X PBS solution up to 24 hours after washed out the fixative solution.</b>

## Step 3: Detection

### **Prepare the cocktail**

1. Firstly, dilute the <b style='color: violet'>Component C</b> and <b style='color: violet'>Component E</b> from 10X to <b style='color: violet'>1X</b> using <b style='color: violet'>ddH<sub>2</sub>O</b>. Calculate the total usage amount according to the following tables.
- 10X Component C is stored at 4&deg;C in the kit box.
- 10X Component E is stored at -20&deg;C in Jhenny's box.
- Prepare the Component C and E as much as necessary only for that day's experiments, and use on the same day.

2. Add the <b style='color: violet'>Click-iT&reg; reaction cocktail</b> ingredients **as follow**. 
- Add the incredients in the order listed in the table; otherwise, the reaction will not proceed optimally. 
- Use the cocktail immediately after preparation. The Click-iT&reg; reaction buffer additive is susceptable to oxidation and is the limiting factor to the Click-iT&reg; reaction cocktail's effectiveness over time.

> | Component | Material name                            | Addition per sample | 4 samples         |
> | :------:  | :--------------------------------------- |:-------------------:|:-----------------:|
> | C         | **1X** Click-iT&reg; EdU reaction buffer | 85 &micro;L         | 340 &micro;L      |
> | D         | CuSO<sub>4</sub>                         | 4 &micro;L          | 16 &micro;L       |
> | B         | Alexa Fluor&reg; azide                   | 0.25 &micro;L       | 1 &micro;L        |
> | E         | **1X** Click-iT&reg; EdU buffer additive | 10 &micro;L         | 40 &micro;L       |
> | Total:    |                                          | ~ 100 &micro;L      | ~ 400 &micro;L    |

### **Incubation**

3. Remove wash solution and add <b style='color: violet'>100 &micro;L</b> of <b style='color: violet'>Click-iT&reg; reaction cocktail</b> ( prepare as the table above ) for each sample;
4. Incubate for <b style='color: violet'>30 minutes</b> at <b style='color: violet'>room temperature</b>. Must be <b style='color: violet'>protected from light</b>;
5. Remove the reaction cocktail and wash once with 100 &micro;L of Click-iT&reg; reaction rince buffer ( <b style='color: violet'>Component F</b> );
6. <b style='color: violet'>Wash 3 times</b> with 1X PBS ( <b style='color: violet'>3 &times; 10 mins</b> );
7. Mounted into <b style='color: violet'>Fluoromount-G anti-fade</b> solution. Proceed to confocal imaging and analysis.

## Step 4: Confocal parameters

| Parameters                                               | Theoretical value | Our machine          |
|:-------------------------------------------------------- |:-----------------:|:--------------------:|
| Excitation peak                                          | 495 nm            | 488 nm               |
| Emission peak                                            | 519 nm            | 500 ~ 600 nm         |
| Magnification                                            |                   | 10X                  |
| Laser intensity ( <b style='color: #97ed1d'>488 nm</b> ) |                   | 0.9%                 |
| Master Gain                                              |                   | 740 V                |
| Pinhole                                                  |                   | &approx; 32 &micro;m |
| Z-stack interval                                         |                   | 2 &micro;m           |
| Scan speed                                               |                   | 8                    |
| Scan direction                                           |                   | <b>&xrarr;</b>       |
|                                                          |                   |                      |

<br>
<div style='page-break-after: always;'></div>

## Step 5: Image processing

1. Use <b style='color: violet'>ImageJ</b> with <b style='color: violet'>bioformats_package.jar</b> plugin to proceed the confocal images;
- The plugin ( bioformats_package.jar ) can be downloaded from <a href='https://www.openmicroscopy.org/bio-formats/downloads/'>https://www.openmicroscopy.org/bio-formats/downloads/</a>

- The plugin should be placed in the <b><i>"/ImageJ/plugins/jars"</i></b> directory
2. Open the confocal .czi file with the ImageJ, the "<b>Bio-Formats Import Options</b>" will automatically pop up;

3. Select the options as follow:

> | Options          | Choose     |
> | :--------------: | :--------: |
> | View stack with: | Hyperstack |
> | Color mode:      | Colorized  |
> | Autoscale        | &#9745;    |

4. Stack the image layers and perform max intensity projection along the Z-axis;
- `Image` &rarr; `Stacks` &rarr; `Z project...` &rarr; `Projection type: Max Intensity`

> Optional: Shows scale bar in the image.  
> `Analyze` &xrarr; `Tools` &xrarr; `Scale Bar...`

5. Save the images as TIFF format;
- `File` &rarr; `Save as` &rarr; `Tiff...`
6. Select the region of interest (ROI) and measure.

<br>
<div style='page-break-after: always;'></div>

<!-- ================================================================================================================= -->
<!-- Materials -->
<!-- ================================================================================================================= -->

# Materials Provided by the kit

| Component            | Material name                           | C10351 <sup>*</sup> | Concentration |
| :-----:              | :-------------------------              | :-----:             | :-----:       |
| A <sup>&alpha;</sup> | EdU **working solution**                | 525 &micro;L        | 10 mM         |
| B <sup>&ensp;</sup>  | Alexa Fluor&reg; azide 488              | 330 &micro;L        | 1X            |
| C <sup>&beta;</sup>  | Click-iT&reg; EdU **reaction buffer**   | 15 mL               | 10X           |
| D <sup>&ensp;</sup>  | CuSO<sub>4</sub>                        | 1 vial              | 100 mM        |
| E <sup>&gamma;</sup> | Click-iT&reg; EdU **buffer additive**   | 400 mg              | 10X           |
| F <sup>&ensp;</sup>  | Click-iT&reg; reaction **rinse buffer** | 125 mL              | 1X            |
|                      |                                         |                     |               |

<sup>*</sup> **C10351**: Catalogue number. All the raw materials in this kit should be stored at <b style='color: violet'>2 ~ 6&deg;C</b>, <b style='color: violet'>dessiccated</b>, <b style='color: violet'>protect from light</b>, and <b style='color: red'>DO NOT FREEZE</b>.  

<sup>&alpha;</sup> **Component A**: This is the EdU chemical stock solution. When in use, dilute to 10 &micro;M to the complete medium for that day's experiments, and use on the same day. The 10 mM stock solution is stored at -20&deg;C ( the EdU powder also put in -20&deg;C, in Jhenny's box ), and the 10 mM aliquots are stored at 4&deg;C (in the EdU kit box, put together with the other components).

<sup>&beta;</sup> **Component C**: Dilute from 10X to 1X using ddH<sub>2</sub>O, *i.e.*, 15 mL 10X Component C + 135 mL ddH<sub>2</sub>O. 
The 1X solution could be stored at 2 ~ 6&deg;C for 6 months.  

<sup>&gamma;</sup> **Component E**: Add 2 mL ddH<sub>2</sub>O to the vial of the Component E, mix until fully dissolve the powder to 10X solution. The <b style='color: violet'>10X solution</b> could be stored at <b style='color: violet'>&leq; &minus;20&deg;C</b> for up to 1 year. If the solution develops a brown color, it has degraded and should be discarded.

<br>
<div style='page-break-after: always;'></div>

# Materials NOT Provided

| Material                                           | Concentration | Storage location      |
| :---------------------------                       | :-----:       |:---------------------:|
| PBS ( Phosphate buffer saline ) <sup>&delta;</sup> | 1X            |                       |
| Fixative solution <sup>&epsi;</sup>                | 4%            |                       |
| Fluoromount-G                                      | --            | 4&deg;C ( D cabinet ) |

### <b><sup>&delta;</sup> 1X PBS ( pH 7.4 )</b>
- Make 10X PBS stock solution first as follow ( 10X stock located at VIII cabinet ). When in use, dilute to 1X PBS.
> | 10X PBS contents              | M.W. (g/mol) | Addition |
> |:----------------------------- |:------------:| --------:|
> | NaCl                          | 58.44        | 80.1 g   |
> | KCl                           | 74.55        | 2.0 g    |
> | Na<sub>2</sub>HPO<sub>4</sub> | 141.96       | 14.4 g   |
> | KH<sub>2</sub>PO<sub>4</sub>  | 136.09       | 2.7 g    |
> | ddH<sub>2</sub>O              |              | 1 L      |
> |                               |              |          |

- 10X PBS &xrarr; Adjust to pH 7.4 &xrarr; Autoclave &xrarr; Dilute to 1X ( 100 mL 10X PBS + 900 mL ddH<sub>2</sub>O )

### <b><sup>&epsi;</sup> Fixative solution</b>
> | Chemical            | Addition      | Final concentration | Storage location |
> |:------------------- | -------------:|:-------------------:|:----------------:|
> | Formaldehyde (38%)  | 105 &micro;L  | 4%                  | Toxic cabinet D  |
> | Triton X-100 (100%) | 1 &micro;L    | 0.1%                | IV               |
> | 1X PBS              | 894 &micro;L  |                     |                  |
> | Total:              | 1000 &micro;L |                     |                  |
