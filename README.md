# FIFA World Cup Squad Age Analysis (1930–2022)

A statistical analysis of FIFA World Cup squad age profiles from 1930 to 2022 using **R**. This project investigates whether the average age of a national team influences its World Cup performance through exploratory data analysis, statistical modeling, and fan survey analysis.

## Project Overview

The relationship between squad age and football performance has long been debated. While experienced teams are often considered more successful, younger squads may possess greater physical intensity and adaptability. This project explores whether squad age has a measurable impact on FIFA World Cup outcomes using historical tournament data.

The analysis includes:

- Data cleaning and preprocessing
- Exploratory Data Analysis (EDA)
- Linear Regression
- Logistic Regression
- One-Way ANOVA
- Assumption Checking
- Non-parametric Statistical Tests
- Fan Survey Analysis
- Data Visualization using ggplot2

---

## Objectives

- Analyze historical trends in FIFA World Cup squad age.
- Compare squad age across football confederations.
- Investigate whether average squad age influences goals scored.
- Examine whether squad age affects qualification for the knockout stage.
- Compare squad age distributions using ANOVA.
- Explore football fans' perceptions regarding squad age and team performance.

---

## Dataset

This project uses the **Fjelstul World Cup Database**, which provides historical FIFA World Cup data.

Data used include:

- Squads
- Players
- Tournaments
- Matches

Additional survey data were collected to compare public opinion with the statistical findings.

---

## Methods

### Data Preparation

- Merged multiple World Cup datasets
- Filtered men's tournaments
- Calculated player ages
- Built team-level summary statistics
- Created knockout qualification indicator

### Exploratory Data Analysis

- Average squad age over time
- Oldest and youngest World Cup squads
- Confederation-wise age comparison
- Distribution of squad ages
- Goals versus squad age

### Statistical Analysis

#### Linear Regression

Examined whether average squad age predicts goals scored.

#### Logistic Regression

Evaluated whether squad age influences the probability of reaching the knockout stage.

#### One-Way ANOVA

Compared average squad ages among different football confederations.

### Assumption Checking

- Residual Diagnostics
- Shapiro-Wilk Normality Test
- Breusch-Pagan Test
- Durbin-Watson Test
- Levene's Test
- Tukey's HSD

### Non-parametric Tests

- Spearman Rank Correlation
- Kruskal-Wallis Test

---

## Survey Analysis

A small football fan survey was conducted to examine perceptions regarding:

- Preferred squad age
- Experienced versus young teams
- Importance of squad age
- Preferred playing style
- Strongest football region

Survey responses were summarized using descriptive statistics and visualizations.

---

## Key Findings

- Average squad age has gradually increased throughout World Cup history.
- Squad age has a statistically significant but weak relationship with goals scored.
- Squad age does not significantly influence qualification for the knockout stage.
- African national teams generally have younger squads than European teams.
- Fans tend to believe the ideal squad age is between 27 and 29 years, closely matching the historical average.

---

## Technologies Used

- R
- tidyverse
- ggplot2
- lubridate
- lmtest
- car

---

## Repository Contents

```
.
├── f_project.R          # Complete R analysis
├── f_project.pdf        # Project report
└── README.md
```

---

## Future Improvements

- Include additional performance metrics (expected goals, possession, shots, etc.)
- Build predictive machine learning models
- Develop an interactive Shiny dashboard
- Expand the fan survey with a larger sample size

---

## Author

**Sourav Ahmed**

Statistics Undergraduate

Interested in:

- Sports Analytics
- Statistical Modeling
- Data Science
- Machine Learning

GitHub: https://github.com/Sourav-93

---

## Acknowledgements

- Fjelstul World Cup Database
- FIFA World Cup historical records
- R Core Team
- tidyverse community
