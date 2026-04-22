---
output:
  html_document:
    theme: 
      version: 4
---

# **Reverse Transcription ( cDNA synthesis )**

### <a href='https://www.thermofisher.com/order/catalog/product/18091050'>SuperScript&trade; IV First-Strand cDNA Synthesis Reaction</a> ( <a href='https://documents.thermofisher.com/TFS-Assets/LSG/manuals/SSIV_First_Strand_Synthesis_System_UG.pdf'>Manual</a> )

# Procedure

## Step 1: Denature template RNA and anneal primers

1. Add the following components in a PCR reaction tube.

| Component                       | Concentration      | 1 sample     | Location                   |
| :---:                           | :---:              | :---:        | :---:                      |
| Oligo d(T)<sub>20</sub> primer  | 50 &micro;M        | 1 &micro;L   | -20&deg;C, 4row-2col-1box  |
| dNTP mix                        | 10 mM              | 1 &micro;L   | -20&deg;C, 4row-2col-1box  |
| RNA template <sup>&alpha;</sup> | 20 ng / &micro;L   | 5 &micro;L   | &mdash;                    |
| Total volume per sample         |                    | 7 &micro;L   |                            |

<sup>&alpha;</sup> Total RNA (10 pg ~ 5 <i>&micro;</i>g) or mRNA (10 pg ~ 500 ng). Generally, we use 100 ng total RNA.

2. Mix and briefly centrifuge the components.

3. Heat the RNA-primer mix at <b style='color: orange'>65&deg;C</b> for <b style='color: orange'>5 minutes</b>, and then incubate on ice for at least 1 minute.

## Step 2: Prepare RT reaction mix

1. Add the following components in a PCR reaction tube. 
- After adding, cap the tube and mix with finger-sliding, and then briefly centrifuge the contents.

| Component                                        | Concentration    | 1 sample     | Location                   |
| :---:                                            | :---:            | :---:        | :---:                      |
| 5X SS&#8547; Buffer <sup>&beta;</sup>            | &mdash;          | 4 &micro;L   | -20&deg;C, 4row-2col-1box  |
| 100 mM DTT                                       | 100 mM           | 1 &micro;L   | -20&deg;C, 4row-2col-1box  |
| Ribonuclease Inhibitor                           | &mdash;          | 1 &micro;L   | -20&deg;C, 4row-2col-1box  |
| SuperScript&trade; &#8547; Reverse Transcriptase | 200 U / &micro;L | 1 &micro;L   | -20&deg;C, 4row-2col-1box  |
| Total volume per sample                          |                  | 7 &micro;L   |                            |

<sup>&beta;</sup> Vortex and briefly centrifuge before use.

## Step 3: Reverse Transcription ( synthesize cDNA )

1. Add <b style='color: orange'>RT reaction mix</b> (from Step 2) to the <b style='color: orange'>RNA-primer mix</b> (from Step 1).

2. Proceed the reaction mixture with the following step:

|       | Temperature (&deg;C) | Time       | Note                    |
| :---: | :---:                | :---:      | :-----:                 |
| 1     | 55&deg;C             | 1 hour     | Incubation              |
| 2     | 80&deg;C             | 10 mins    | Inactivate the reaction |
| 3     | 4 &deg;C             | &infin;    | Finish and keep         |

3. Store the cDNA at &minus;20&deg;C.

### (Optional): Remove RNA
Amplification of some PCR targets ( > 1 kb ) may require removal of RNA.

1. Add 1 &micro;L <i>E. coli</i> RNase H, and incubate at 37&deg;C for 20 minutes.

## Step 4: cDNA quantification with Qubit&trade;
Similar with the RNA procedure, but use different working solution. The working solution is the HS buffer which already contained dye. Standard 1 buffer is blank TE buffer and Standard 2 contains 10 ng / uL DNA in TE buffer.

- Working solution: Located at &minus;80&deg;C ( 2row-4col-3box )
- Standard 1: Located at 4&deg;C (a, right)
- Standard 2: Located at &minus;80&deg;C ( 2row-4col-1box )


