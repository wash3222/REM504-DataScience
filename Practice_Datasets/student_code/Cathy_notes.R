g <- ggplot(data = BigFoot_Graph4, aes(x = State, y = Num of ))
g + geom_boxplot()
names(BigFoot_Graph4)
names(BigFoot_Graph4$`Num of Conf Sight`) <- "Sightings"
BigFoot_Graph4
##grid.arrange is another package where you can arrange plots next to each other
## 
g <- ggplot(data = BigFoot_Graph4, aes(x = State, y = Sightings, main= Number of Confirmed Sightings))
##panel.spacing under theme 
##ggridges
## people tend to google stack exchange to figure out what to search, what is avialable, and what to use for
#representing data. ggplot2 can give you examples of what your code will look like and may also provide you with the code
# geompath

#title(main = "Bigfoot Sightings in US")
#vectir graphics dont save as an image, they save the vector component
#that is the outline of a letter and you can move it around thorugh inkscape
#