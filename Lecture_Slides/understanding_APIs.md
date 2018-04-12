# Understanding APIs for Data Access
<img src="./img/OReilly_Restful_APIs.jpg" width="60%" height="60%">
The use of Application Programming Interfaces (APIs, also called Web Services) for data access and download is becoming increasingly popular. An API transfers data over the web via HTTP protocols. However, there are lots of different styles/flavors of APIs, and their use (and usefulness) isn't always clear. In order to understand how, when, and why you'd want to use an API (and as importantly how, when and why NOT), we need to cover some basic concepts of APIs and web protocols.

## HTTP protocol - how the web works
HTTP is the basic network protocol upon which the internet operates. There are entire tomes written on HTTP, but the basic structure revolves around a set of servers and clients. The clients send __requests__ to the servers and the servers return __responses__. A client request consists of three main parts:
1. The request - the most common requests are GET and POST. GET asks for information (including data) from a server. POST is used to send data to a server.
2. headers - information the server requires to process your request. This can vary and some APIs require specialized headers. This part is usually hidden from the user.
3. an optional body or message. For POST requests, the data would go here.

The server response has the following parts:
1. Initial Response or Status Line - This gives the status of the request and is super useful information to have. The server will (or should) always respond to a request. It will not, however, always return data to you The status line tells you what happened. Common status codes are:
| Code | Meaning |
| --- | --- |
| 200 | OK, request processed successfully |
| 30X | X is a number. Resource has moved to a different URL |
| 404 | Not Found. This is the one we're most familiar with |
| 500 | Server Error |
The server can also return custom status codes that can be used for specialized data retrieval.
2. Header lines - Response headers contain info like the date/time of the request, what type of server it was, and information on __pagination__ (see below).
3. Message body - this is the data the server is actually returning. In the case of a web page you requested from your browser, it's HTML, javascript, images, etc. In the case of a data API, it's the data you requested.

### Pagination
It is really easy to overwhelm data APIs and servers with large requests. If you make a request that is too large, you can grind the server to a halt (basically akin to a Denial of Service attack). To prevent this, many APIs will implement some sort of throttling (rate limitations, request size limits) or other means of protecting the server from requests that it can't efficiently handle. One means of doing this is pagination, where the results above a certain size (i.e., number of records) are split into sets and returned as "pages." The initial request returns just the first page, and the response header includes information on which page you are on, how many pages there are total, and a URL for requesting additional pages. _I really hate pagination. It's a pain to deal with because you have to iterate over all the pages and then reassemble the dataset._ It's important to be aware of it, though.

## RESTful APIs
Early APIs worked by submitting a lot of query parameters through the request header. While this worked, it was a royal pain and had to be done via programming packages - i.e., you couldn't easily do it via the browser. More recently, the trend has been toward producing RESTful (Representational State Transfer if you were curious) APIs where the header information is minimal and all the query and server instructions are passed through the URL itself. While generally slower (see graphic above), these APIs are much friendlier to use because you can develop and test queries via a web browser. For the sake of sanity, we'll deal with RESTful APIs here.

## Web Data Formats
The format of data you get from an API can vary a lot. Web severs will return HTML (you can call a web server from within R and return the HTML. Useful if you want to do some text mining or data scraping). Other web services like ArcGIS feature or image data services return data in specialized data or image formats. Some web service APIs return .ZIP files for download.

Two common data formats used by APIs to accept or return data, though, are eXtensible Markup Language (XML) or JavScript Object Notation (JSON). Both of these formats are plain-text based and work well in the context of data transfer over the web.

### XML
XML is a generalized form of HTML (or more accurately, HTML is a specific form of XML). XML uses __tags__ to denote different data elements. For example:
```
<data>
    <site>forest123</site>
    <precip>25.4</precip>
    <temp>23.1</temp>
    <solarirrad>456</solarirrad>
</data>
```
This simple example stores some observational data from a site. XML is really flexible because you can just define whatever tags you want. You can add attributes to the tags to convey additional information like units.
```
<precip units="mm">25.4</precip>
```
XML can be used to transfer tabular data (e.g., a data table), unstructured or loosely structured data (e.g., citation info for an article), or a mix of the two (e.g., put the tabular data inside one tag and the unstructured data inside another).

XML data are just text, so to extract data from it in R, you need to parse it to convert it to a data structure. The XML package in R is useful for reading and extracting info from XML data.

The following link has some helpful information: [https://www.w3schools.com/xml/xml_whatis.asp]

### JSON
The format of JSON is similar to XML, and JSON has the same properties of flexibility and extensibility. JSON is considered to be a self-describing data format - all the info you need to understand the data should be included and JSON (when properly formatted) is easy to read and understand. JSON consists of a collection of name/value pairs written in JavaScript format.

A JSON data string always starts and ends with curly braces. You then list the names and data values for each data element. The power of JSON comes in that you can nest these data elements.
```
{
  "data1":{
    "site":"forest123",
    "precip":25.4,
    "temp":23.1,
    "solarirrad":456
  },
  "data2":{
    "site":"forest345",
    "precip":28.2,
    "temp":19.3,
    "solarirrad":158  }
}
```
Like XML, you need to read the JSON data into R and then parse it so that R can recognize it as a JSON data structure. You can use the __jsonlite__ package in R to do this.

The following link has some helpful information: [https://www.w3schools.com/js/js_json_intro.asp]
