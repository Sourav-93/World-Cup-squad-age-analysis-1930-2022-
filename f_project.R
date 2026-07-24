# Project: Does Squad Age Decide World Cup Fate?

# Phase 1: Load datasets

library(tidyverse)
library(lubridate)

squads      <- read_csv("https://raw.githubusercontent.com/jfjelstul/worldcup/master/data-csv/squads.csv")
players     <- read_csv("https://raw.githubusercontent.com/jfjelstul/worldcup/master/data-csv/players.csv")
tournaments <- read_csv("https://raw.githubusercontent.com/jfjelstul/worldcup/master/data-csv/tournaments.csv")
matches     <- read_csv("https://raw.githubusercontent.com/jfjelstul/worldcup/master/data-csv/matches.csv")

glimpse(squads)
glimpse(players)
glimpse(tournaments)

View(tournaments)
View(matches)

# Phase 2: Data Cleaning 

# Filter to men's only
tournaments_men <- tournaments %>%
  filter(!str_detect(tournament_name, "Women"))

players_men <- players %>%
  filter(female == 0)


# Join everything together
squads_full <- squads %>%
  left_join(players_men %>% select(player_id, birth_date),
            by = "player_id") %>%
  left_join(tournaments_men %>% select(tournament_id, year, start_date, winner),
            by = "tournament_id")


# Calculate player ages
squads_full <- squads_full %>%
  mutate(
    birth_date = as.Date(birth_date),
    age = year - year(birth_date)
  )


# Remove bad/missing ages
squads_full <- squads_full %>%
  filter(!is.na(age)) %>%
  filter(age >= 15, age <= 50)

summary(squads_full$age)
nrow(squads_full)


# Build squad summary table
squad_summary <- squads_full %>%
  group_by(tournament_id, year, team_name) %>%
  summarise(
    avg_age    = mean(age),
    age_sd     = sd(age),
    min_age    = min(age),
    max_age    = max(age),
    squad_size = n(),
    .groups    = "drop"
  )

# Add knockout variable
home_knockout <- matches %>%
  filter(knockout_stage == 1) %>%
  select(tournament_id, team_name = home_team_name) %>%
  mutate(reached_knockout = 1)

away_knockout <- matches %>%
  filter(knockout_stage == 1) %>%
  select(tournament_id, team_name = away_team_name) %>%
  mutate(reached_knockout = 1)

knockout_teams <- bind_rows(home_knockout, away_knockout) %>%
  distinct()

squad_summary <- squad_summary %>%
  left_join(knockout_teams, by = c("tournament_id", "team_name")) %>%
  mutate(reached_knockout = ifelse(is.na(reached_knockout), 0, 1))

table(squad_summary$reached_knockout)

head(squad_summary, 10)
nrow(squad_summary)

# Phase 3: Data Analysis

summary(squad_summary$avg_age)
summary(squad_summary$age_sd)

# Which tournament had the oldest and youngest squads on average?
squad_summary %>%
  group_by(year) %>%
  summarise(mean_age = mean(avg_age)) %>%
  arrange(desc(mean_age))

# Has average squad age changed over the decades?
squad_summary %>%
  group_by(year) %>%
  summarise(mean_age = mean(avg_age)) %>%
  print(n = 22)

# Top 10 oldest squads
squad_summary %>%
  arrange(desc(avg_age)) %>%
  select(year, team_name, avg_age) %>%
  head(10)

# Top 10 youngest squads
squad_summary %>%
  arrange(avg_age) %>%
  select(year, team_name, avg_age) %>%
  head(10)

# Add confederation manually
squad_summary <- squad_summary %>%
  mutate(confederation = case_when(
    team_name %in% c("Germany", "France", "Spain", "England",
                     "Italy", "Netherlands", "Portugal", "Belgium",
                     "Croatia", "Denmark", "Sweden", "Switzerland",
                     "Poland", "Serbia", "Czech Republic", "Hungary",
                     "Romania", "Scotland", "Turkey", "Ukraine",
                     "West Germany", "Soviet Union", "Yugoslavia",
                     "Czechoslovakia", "East Germany", "Austria",
                     "Bulgaria", "Norway", "Slovakia", "Slovenia",
                     "Wales", "Northern Ireland", "Greece", "Russia") ~ "UEFA",
    team_name %in% c("Brazil", "Argentina", "Uruguay", "Colombia",
                     "Chile", "Paraguay", "Peru", "Ecuador",
                     "Bolivia") ~ "CONMEBOL",
    team_name %in% c("USA", "Mexico", "Costa Rica", "Honduras",
                     "El Salvador", "Cuba", "Canada",
                     "Trinidad and Tobago", "Haiti",
                     "Jamaica") ~ "CONCACAF",
    team_name %in% c("Nigeria", "Senegal", "Ghana", "Cameroon",
                     "Morocco", "Tunisia", "Ivory Coast", "Algeria",
                     "South Africa", "Egypt", "Togo", "Angola",
                     "Democratic Republic of the Congo",
                     "Zaire") ~ "CAF",
    team_name %in% c("Japan", "South Korea", "Australia",
                     "Saudi Arabia", "Iran", "Iraq", "China",
                     "North Korea", "UAE", "Kuwait",
                     "Indonesia") ~ "AFC",
    TRUE ~ "Other"
  ))

# Compare average age by confederation
squad_summary %>%
  group_by(confederation) %>%
  summarise(
    mean_age   = round(mean(avg_age), 2),
    teams      = n()
  ) %>%
  arrange(desc(mean_age))


# Phase 4: Visualization
squad_summary %>%
  group_by(year) %>%
  summarise(mean_age = mean(avg_age)) %>%
  ggplot(aes(x = year, y = mean_age)) +
  geom_line(color = "steelblue", size = 1.2) +
  geom_point(color = "tomato", size = 3) +
  labs(title = "Average Squad Age at World Cup (1930–2022)",
       x = "Year", y = "Average Age") +
  theme_minimal()

squad_summary %>%
  filter(confederation != "Other") %>%
  ggplot(aes(x = reorder(confederation, avg_age),
             y = avg_age, fill = confederation)) +
  geom_boxplot(show.legend = FALSE) +
  labs(title = "Squad Age by Confederation",
       x = "", y = "Average Age") +
  theme_minimal()

squad_summary %>%
  arrange(desc(avg_age)) %>%
  head(10) %>%
  mutate(label = paste(team_name, year)) %>%
  ggplot(aes(x = reorder(label, avg_age), y = avg_age)) +
  geom_col(fill = "tomato") +
  coord_flip() +
  labs(title = "Top 10 Oldest Squads Ever",
       x = "", y = "Average Age") +
  theme_minimal()

squad_summary %>%
  arrange(avg_age) %>%
  head(10) %>%
  mutate(label = paste(team_name, year)) %>%
  ggplot(aes(x = reorder(label, desc(avg_age)), y = avg_age)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 10 Youngest Squads Ever",
       x = "", y = "Average Age") +
  theme_minimal()

goals_data <- matches %>%
  group_by(tournament_id, home_team_name) %>%
  summarise(goals = sum(home_team_score, na.rm = TRUE), .groups = "drop") %>%
  rename(team_name = home_team_name)

squad_summary <- squad_summary %>%
  left_join(goals_data, by = c("tournament_id", "team_name"))

squad_summary %>%
  filter(!is.na(goals)) %>%
  ggplot(aes(x = avg_age, y = goals)) +
  geom_point(color = "steelblue", alpha = 0.6) +
  geom_smooth(method = "lm", color = "tomato") +
  labs(title = "Does Squad Age Predict Goals Scored?",
       x = "Average Squad Age", y = "Goals Scored") +
  theme_minimal()


View(squad_summary)

# Phase 5: Statistical Modeling

# Simple Linear Regression 

model1 <- lm(goals ~ avg_age, data = squad_summary)
summary(model1)

# Model adequacy checking
par(mfrow = c(2, 2))
plot(model1)
par(mfrow = c(1, 1))

shapiro.test(model1$residuals)

library(lmtest)
bptest(model1)

dwtest(model1)

# Logistic Regression

model2 <- glm(reached_knockout ~ avg_age,
              data   = squad_summary,
              family = binomial)

summary(model2)

table(squad_summary$reached_knockout)


# ANOVA

model3 <- aov(avg_age ~ confederation,
              data = squad_summary %>%
                filter(confederation != "Other"))
summary(model3)

shapiro.test(model3$residuals)

#Levene's test for Homogeneity of variance
library(car)
leveneTest(avg_age ~ confederation,
           data = squad_summary %>%
             filter(confederation != "Other"))

TukeyHSD(model3)


# Non-parametric test for linear regression
cor.test(squad_summary$avg_age, 
         squad_summary$goals, 
         method = "spearman",
         use = "complete.obs")

# Non-parametric test for ANOVA
kruskal.test(avg_age ~ confederation,
             data = squad_summary %>%
               filter(confederation != "Other"))


# Phase 6: Survey Analysis

survey <- read_csv("E:/World Cup Project/fifa survey.csv") %>%
  rename(
    follow_wc        = 1,
    experienced_win  = 2,
    youth_underrated = 3,
    ideal_age        = 4,
    play_style       = 5,
    best_region      = 6,
    age_affects      = 7
  )

glimpse(survey)

table(survey$follow_wc)
table(survey$ideal_age)
table(survey$play_style)
table(survey$best_region)

summary(survey$experienced_win)

summary(survey$youth_underrated)

summary(survey$age_affects)


# Chart 1 - How closely do respondents follow WC?
ggplot(survey, aes(x = follow_wc, fill = follow_wc)) +
  geom_bar(show.legend = FALSE) +
  labs(title = "How Closely Do Respondents Follow the World Cup?",
       x = "", y = "Count") +
  theme_minimal()

# Chart 2 - Preferred playing style
ggplot(survey, aes(x = play_style, fill = play_style)) +
  geom_bar(show.legend = FALSE) +
  coord_flip() +
  labs(title = "Preferred Playing Style",
       x = "", y = "Count") +
  theme_minimal()

# Chart 3 - Strongest region
ggplot(survey, aes(x = best_region, fill = best_region)) +
  geom_bar(show.legend = FALSE) +
  labs(title = "Which Region Produces Strongest Squads?",
       x = "", y = "Count") +
  theme_minimal()


# Experienced squads (older players) perform better at the World Cup?
ggplot(survey, aes(x = factor(experienced_win))) +
  geom_bar(fill = "steelblue") +
  labs(title = "Experienced Squads Win Better",
       x = "Response (1=Disagree, 5=Agree)",
       y = "Count") +
  theme_minimal()

# Young squads are underestimated at the World Cup?
ggplot(survey, aes(x = factor(youth_underrated))) +
  geom_bar(fill = "orange") +
  labs(title = "Young Squads Are Underrated",
       x = "Response (1=Disagree, 5=Agree)",
       y = "Count") +
  theme_minimal()

# Squad age significantly affects World Cup results?
ggplot(survey, aes(x = factor(age_affects))) +
  geom_bar(fill = "darkgreen") +
  labs(title = "Squad Age Affects World Cup Results",
       x = "Response (1=Disagree, 5=Agree)",
       y = "Count") +
  theme_minimal()

###############################################################################

