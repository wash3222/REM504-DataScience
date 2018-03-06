###### SETUP
# Attach the package we'll be using
# Almost everything is in the tidyverse, praise Wickham
library(tidyverse)

# Read in our data set
# These are vegetation heights
# Note that you'll need to change the filepath to wherever your own mirror of the git repo lives!
data.raw <- read.csv("C:/Users/Nelson/Documents/Projects/GitHub/REM504-DataScience/Practice_Datasets/student_data/aimhaf_point_combined.csv",
                      stringsAsFactors = FALSE)

# I regret my capitalization scheme, so let's undo it
names(data.raw) <- str_to_lower(names(data.raw))

# I want the mean and standard deviation of the heights by plot
data.summarized <- data.raw %>% select(-(x:projectname),
                                       -(lineid:meter.mark),
                                       -matches("species"),
                                       -matches("duration"),
                                       -matches("habit")) %>%
  group_by(plotid) %>%
  summarize_all(funs(mean), na.rm = TRUE)

# We'll want a tall/long version of this later (I think)
data.tall <- data.summarized %>% gather(key = type,
                                        value = measurement,
                                        -(plotid)) %>%
  mutate(method = str_extract(type,
                              pattern = "aim|haf"),
         type = str_replace(type,
                            pattern = "^(aim|haf)\\.",
                            replacement = ""))

# And another version of the raw data, just with the method used to split data by rows
data.wide <- data.tall %>% spread(key = type,
                                  value = measurement)

###### PLOTTING
### What happens with the bare minimum?
ggplot(data = data.wide)

###### COMMON GEOMS
### Scatterplot
ggplot(data = data.summarized) +
  geom_point(aes(x = aim.height.woody,
                 y = haf.height.woody),
             color = "blue")

### Histogram
## What the heck is the difference between geom_col() and geom_bar()????
# geom_col() will make bars with heights matching the values in the y aesthetic
ggplot(data = data.summarized) +
  geom_col(aes(x = plotid,
               y = aim.height.woody))

# geom_bar() will take the values and group them by the x variable
# The stat argument has a few options you can explore
ggplot(data = data.tall) +
  geom_bar(aes(x = plotid,
               color = method))

### Labels
ggplot(data = data.summarized) +
  geom_col(aes(x = plotid,
               y = aim.height.woody,
               fill = plotid)) +
  labs(title = "Height measurements by method per plot") +
  theme(legend.position = "none")

##### GETTING FANCY
### Multiple geoms
ggplot(data = data.summarized) +
  geom_point(aes(x = aim.height.woody,
                 y = haf.height.woody),
             color = "blue") +
  geom_smooth(aes(x = aim.height.woody,
                  y = haf.height.woody),
              method = "lm",
              color = "red")

### Flipping coordinates
# This is great for horizontal bar charts!
ggplot(data = data.summarized) +
  geom_point(aes(x = aim.height.woody,
                 y = haf.height.woody),
             color = "blue") +
  geom_smooth(aes(x = aim.height.woody,
                  y = haf.height.woody),
              method = "lm",
              color = "red") +
  coord_flip()

### Faceting
questionable.figure <- ggplot(data.wide) +
  geom_point(aes(x = height.pf,
                 y = height.pg,
                 color = method)) +
  geom_smooth(aes(x = height.pf,
                  y = height.pg),
              method = "lm") +
  facet_wrap(~method)

### Exporting a figure as a 150 DPI .png file called export.png into the current working directory
ggsave(plot = questionable.figure,
       filename = "example",
       device = "png",
       dpi = 150)
