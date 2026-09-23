# ecosystem-representativeness-indicators

*Testing different indicators for tracking progress in effective, representative ecosystem protection*

#### PUBLICATION

Harris, L.R., et al. XXXX. Indicators for tracking progress in effective, representative ecosystem protection. Conservation Biology, accepted manuscript. doi: XXXX

#### CODE STRUCTURE AND NOTES

-   The code was written in short scripts. The scripts named .0\_...master... then serve as master scripts that source each of the scripts for a section (A, B, C, D, E) that - in turn - output a figure (or theme of figures) for the above paper. You can either run the master scripts, or each individual script in order. Note, though, that there are often dependencies on objects and values calculated in previous scripts, so it's best to run everything sequentially.

-   The indicators originally used the term 'representivity', which was changed to 'representativeness' in the peer-review process (where both words mean the same thing but the latter term is more widely used). Although the figure legends and labels were updated to reflect this change, the original terminology is still in the code.

-   There are faster approaches for some analyses using raster-based methods, but given the small size of some of the ecosystems types, we chose a vector-based approach, which is a bit longer to run but more spatially accurate.

-   See the paper for data sources. Another useful website with related datasets and resources is: <https://nba.sanbi.org.za/>

#### SECTION A: Protected Area Coverage, Representativeness, Condition-Adjusted Representativeness, Representativeness Index, and Condition-Adjusted Representativeness Index by country

*This section includes the scripts to calculate the indicators described in Sections 2.2.1 and 2.2.2 of the paper , with outputs presented in Section 3.1.*

-   **A0:** Master script; outputs **Figure 3b,c** for the paper

-   **A1:** Loads the data and inputs

-   **A2:** Calculates Protected Area Coverage at a national scale

-   **A3:** Calculates Representativeness and Representativeness Index at a national scale [script takes a while to run]

-   **A4:** Calculates Condition-Adjusted Representativeness and Condition-Adjusted Representativeness Index at a national scale [script takes a long time to run]

-   **A5:** Outputs **Figure 3b,c** for the paper

#### SECTION B: Ecosystem Protection Level and Ecosystem Protection Level Index by ecosystem groups (realm, and IUCN Global Ecosystem Typology levels)

*This section includes the scripts to calculate the indicators in Sections 2.3.2 and 2.3.3 of the paper, with outputs presented in Section 3.2 and the Supplementary.*

-   **B0:** Master script; outputs **Figure 4b,c,d** and **Figure S3** for the paper

-   **B1:** Sets up inputs and plots

-   **B2:** Calculates Ecosystem Protection Level at a realm level; produces **Figure 4b,c**

-   **B3:** Calculates Ecosystem Protection Level Index at a realm level; outputs **Figure 4d** for the paper

-   **B4**: Calculates Ecosystem Protection level using IUCN GET groups; outputs Supplementary **Figure S3** for the paper

#### SECTION C: Protected Area Coverage, Representativeness, Condition-Adjusted Representativeness by ecosystem groups (realm, and IUCN Global Ecosystem Typology levels)

*This section includes the scripts to calculate the indicators in Section 2.3.4 of the paper, with outputs presented in Section 3.2 and in the Supplementary.*

-   **C0:** Master script; outputs **Figure 5** and **Figure S4** for the paper

-   **C1:** Sets up inputs and plots

-   **C2:** Calculates Protected Area Coverage, Representativeness, Condition-Adjusted Representativeness by realm; outputs **Figure 5** for the paper [script takes a long time to run]

-   **C3:** Calculates Protected Area Coverage, Representativeness, Condition-Adjusted Representativeness by IUCN GET Level 3; outputs Supplementary **Figure S4** for the paper [script takes a while to run]

#### SECTION D: Protected Area Coverage, Representativeness, Condition-Adjusted Representativeness and Ecosystem Protection Level by ecosystem types

*This section includes the scripts to calculate the indicators in Section 2.4.1 of the paper, with outputs presented in Section 3.3.*

-   **D1:** Calculates Protected Area Coverage, Representativeness, Condition-Adjusted Representativeness and Ecosystem Protection Level per ecosystem type; outputs **Figure 6** for the paper

#### SECTION E: Condition-Adjusted Representativeness and Ecosystem Protection Level Index at the IUCN GET levels, recommended for inclusion in the monitoring framework for the Kunming-Montreal Global Biodiversity Framework (for Target 3)

*This section includes the scripts to calculate the indicators in Section 2.5 of the paper, with outputs presented in Section 3.4 and the Discussion.*

-   **E0:** Master script; outputs **Figure 7** for the paper

-   **E1:** Sets up function for the EPLI plot using the IUCN GET

-   **E2:** Calculates Ecosystem Protection Level Index using IUCN GET groups

-   **E3:** Calculates Condition-Adjusted Representativeness Index using IUCN GET groups; outputs **Figure 7** for the paper
