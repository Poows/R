library('shiny')               
library('lattice')             
library('data.table')          
library('ggplot2')             
library('dplyr')               
library('lubridate')           
library('zoo')
library('RCurl')

source("https://raw.githubusercontent.com/aksyuk/R-data/master/API/comtrade_API.R")

getwd()

code = c('0701', '0702', '0703', '0704', '0705')
DF = data.frame()
for (i in code){
  for (j in 2010:2020){
    Sys.sleep(5)
    s1 <- get.Comtrade(r = 'all', p = 643,
                       ps = as.character(j), freq = "M",
                       cc = i, fmt = 'csv')
    DF <- rbind(DF, s1$data)
    print(paste("Данные для кода ", i, "and", j, "загружены"))
  }
}

file.name <- paste('./data/product_data.csv', sep = '')
write.csv(DF, file.name, row.names = FALSE)

write(paste('Файл',
            paste('product_data.csv', sep = ''),
            'загружен', Sys.time()), file = './data/download.log', append=TRUE)


DF <- read.csv('./data/product_data.csv', header = T, sep = ',')
DF <- DF[, c(2, 4, 8, 10, 22, 30, 32)]

DF <- DF[!is.na(DF$Netweight..kg.) & !is.na(DF$Trade.Value..US..), ]
DF

# Код продукции
filter.1 <- as.character(unique(DF$Commodity.Code))
names(filter.1) <- filter.1
filter.1 <- as.list(filter.1)
filter.1

filter.2 <- as.character(unique(DF$Trade.Flow))
names(filter.2) <- filter.2
filter.2 <- as.list(filter.2)
filter.2

file.name <- paste('./data/product_data2.csv', sep = '')
write.csv(DF, file.name, row.names = FALSE)

DF <- read.csv('./data/product_data2.csv', header = T, sep = ',')
DF

df.filter <- DF[DF$Commodity.Code == filter.1[2] & DF$Trade.Flow == filter.2[3], ]
df.filter


gp <- ggplot(data = df.filter, aes_string(x = df.filter$Netweight..kg., y = df.filter$Trade.Value..US..))
gp <- gp + geom_point() + geom_smooth(method = 'lm')
gp

# Запуск приложения
runApp('./app', launch.browser = TRUE,
       display.mode = 'showcase')
