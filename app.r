library(shiny)
library(leaflet)
library(httr)
library(jsonlite)
library(rgdal)
library(gdata)

fetch_data<-function(){
  base <- "https://services5.arcgis.com/ACaLB9ifngzawspq/arcgis/rest/services/COVID19County_ViewLayer/FeatureServer/0/query?where=Count_%3C%3E0&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=*&returnGeometry=false&returnCentroid=false&featureEncoding=esriDefault&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=false&cacheHint=true&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pjson&token="
  data_project_json <- fromJSON(base)
  json<-data_project_json[['features']]
  
  grabInfo<-function(var){
    print(paste("Variable", var, sep=" "))  
    sapply(json, function(x) returnData(x, var)) 
  }
  returnData<-function(x, var){
    if(!is.null( x[[var]])){
      return( trim(x[[var]]))
    }else{
      return(NA)
    }
  }
  fmDataDF<-data.frame(sapply(1:11, grabInfo), stringsAsFactors=FALSE)
  colnames(fmDataDF)[4]<-"CNTY_FIPS"
  fmDataDF
}

fetch_map<-function()
{
    texas.map
  }


# UI function
ui <- bootstrapPage(HTML('<meta name="viewport" content="width=1024">'),tags$head(tags$style(HTML('body, label, input, button, select { 
            font-family: "Calibri";
            background-color: grey;
        }'))),
                 navbarPage("Texas Covid-19",
                 tabPanel('Overview',leafletOutput("mymap"),
                          tags$h1(textOutput("tot_count")),
                          tags$h1(textOutput("deat_count")),
                          tags$h1(textOutput('report'))),
                          
                 tabPanel("County-level",tags$h1("Texas County-Level Summary"),
                          column( 12,align="center",tableOutput('County_table')))
                ))

server <- function(input, output, session) {
  cen_data<-fetch_data()
  
  output$tot_count <- renderText({ 
    tot_count<- as.numeric(cen_data$X7)
    tot_count<-sum(tot_count)
    tot_count #Cases Reported
    paste("Total Cases Reported:",tot_count)
  })
  output$deat_count<-renderText({
    death_count<-as.numeric(cen_data$X11)
    death_count <- death_count[!is.na(death_count)]
    death_count<-sum(death_count)
    death_count
    paste("Fatalities:",death_count)
  })
  output$report<-renderText({
    CN<-length(cen_data$X3)
    paste("Total Counties Reporting:",CN,"/ 254")
  })
  
  
  
  output$County_table <- renderTable({
    table_summary<-cen_data
    colnames(table_summary)
    df <- subset(table_summary, select = -c(X1,X2,CNTY_FIPS,X5,X6,X8,X9,X10))
    colnames(df)[1]<-"County Names"
    colnames(df)[2]<-"Total Patients Reported"
    colnames(df)[3]<-"Death Count"
    df[is.na(df)] <- 0
    df
  })
  
  output$mymap <- renderLeaflet({
    mod_data<-cen_data
    mod_data$X7<-as.numeric(mod_data$X7)
    texas.map <- readOGR(dsn= './Data', layer = "Texas_County_Boundaries_Detailed", stringsAsFactors = FALSE)
    leafmap <- merge(texas.map,mod_data, by=c("CNTY_FIPS"))
    
    
    # Format popup data for leaflet map.
    popup_dat <- paste0("<strong>County: </strong>", 
                        leafmap$CNTY_NM, 
                        "<br><strong>Cases: </strong>", 
                        leafmap$X7)
    
    pal <- colorNumeric("YlOrRd", NULL, n = 20)
   
     # Render final map in leaflet.
    leaflet(data = leafmap) %>% addTiles() %>%
      addPolygons(data=leafmap,fillColor = ~pal(X7), 
                  fillOpacity = 0.8, 
                  color = "#fcfcfc", 
                  weight = 1,
                  popup = popup_dat)
  })
}

shinyApp(ui, server)
