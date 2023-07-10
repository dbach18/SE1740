<%@page import="java.util.Comparator"%>
<%@page import="java.util.Collections"%>
<%@page import="model.Account"%>
<%@page import="model.Watch"%>
<%@page import="java.util.ArrayList"%>
<%@page import="DAL.WatchDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix = "c" uri = "http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Welcome Page</title>
        <link rel="stylesheet" href="css/WelcomeStyleindex.css">
        <link href="css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body>
        <div class="row1">
            <div class="collapse navbar-collapse" id="navbar">
                <ul>
                    <li><a href="WelcomePage.jsp">Home</a></li>
                    <li><a href="WelcomePage.jsp">Shop</a></li>
                        <%
                            //check if the user is logged in or not
                            Account acc = (Account) session.getAttribute("user");
                            if (acc == null) {
                        %>
                    <li><a href="Login.jsp">Login</a></li>
                    <li><a href="Register.jsp">Register</a></li>
                        <%} else {
                        %>
                    <li><p>Welcome <%= acc.getUsername()%></p></li>
                    <li><a href="LogOutServlet">Log out</a></li>
                    <li><a href="ViewOrders.jsp">View Orders</a></li>
                        <%
                            }
                        %>
                </ul>

                <!-- Search form -->
                <form class="navbar-form navbar-right" action="SearchServlet" method="GET" role="search">
                    <input name="searchResult" type="text" placeholder="Search">
                </form>
            </div>
        </div>
        <div class="watchesContainer">
            <img class="itemimg" src="images/11062b_2a28ff5b16904be5bde7a89ad3d5fc25~mv2_d_3000_2000_s_2.webp" width="500" height="500px"/>
            <div class="sectioc-middle">
                <h3>Wrist Watches</h3>
                <%
                    int pageId;
                    //retrieve page, page is set to 1 by default
                    try {
                        pageId = Integer.parseInt(request.getParameter("page"));
                    } catch (NumberFormatException e) {
                        pageId = 1;
                    }
                    //get search result, it is set to "" by default to get all watches
                    String search = (String) request.getAttribute("searchResult");
                    if (search == null) {
                        search = request.getParameter("searchResult");
                    }
                    if (search == null || search.equalsIgnoreCase("null")) {
                        search = "";
                    }
                    WatchDAO db = new WatchDAO();
                    ArrayList<Watch> watches = db.getWatches();
                    if (watches == null) {
                        out.println("Cannot get the data");
                    } else {
                        //set max number of page
                        int maxPage = (int) watches.size()/9+1;
                %>
                <div class="pagination">
                    <p>Page</p>
                    <%
                        //when should ">>" and "<<" signs appear
                        if (pageId > 1) {
                    %>
                    <a href="WelcomePage.jsp?page=<%= pageId - 1%>&&selectedValue=<%=request.getParameter("selectedValue")%>&&searchResult=<%=request.getParameter("searchResult")%>">&laquo;</a>
                    <%
                        }
                    %>
                    <%
                        for (int i = 1; i <= maxPage; i++) {
                    %>
                    <a href="WelcomePage.jsp?page=<%= i%>&&selectedValue=<%=request.getParameter("selectedValue")%>&&searchResult=<%=request.getParameter("searchResult")%>"><%= i%></a>
                    <%
                        }
                    %>
                    <%
                        if (pageId < maxPage) {
                    %>
                    <a href="WelcomePage.jsp?page=<%= pageId + 1%>&&selectedValue=<%=request.getParameter("selectedValue")%>&&searchResult=<%=request.getParameter("searchResult")%>">&raquo;</a>
                    <%
                        }
                    %>
                </div>
                <div class="sort-by">
                    Sort by:
                    <select name="sort" id="sortSelect">
                        <option value="sort" selected hidden>Select an option</option>
                        <option value="default">Default</option>
                        <option value="high-to-low">Price (High to low)</option>
                        <option value="low-to-high">Price (Low to high)</option>
                    </select>
                </div>
                <script>
                    //script to check the user choice in the sort By dropdown menu 
                    document.getElementById("sortSelect").addEventListener("change", function () {
                        var selectedValue = this.value;
                        window.location.href = "WelcomePage.jsp?searchResult=<%=request.getParameter("searchResult")%>&&page=<%= pageId%>&&selectedValue=" + encodeURIComponent(selectedValue);
                    });
                </script>
                <%
                    //sort the watches, they are sorted by id by default
                    ArrayList<Watch> sortedWatches = new ArrayList<>(watches);
                    String sort = request.getParameter("selectedValue");
                    if (sort == null || sort.equalsIgnoreCase("default")) {
                        Collections.sort(sortedWatches, new Comparator<Watch>() {
                            public int compare(Watch o1, Watch o2) {
                                return (int) (o1.getWatchId() - o2.getWatchId());
                            }
                        });
                    } else if (sort.equalsIgnoreCase("high-to-low")) {
                        Collections.sort(sortedWatches, new Comparator<Watch>() {
                            public int compare(Watch o1, Watch o2) {
                                return (int) (o2.getPrice() - o1.getPrice());
                            }
                        });
                    } else if (sort.equalsIgnoreCase("low-to-high")) {
                        Collections.sort(sortedWatches, new Comparator<Watch>() {
                            public int compare(Watch o1, Watch o2) {
                                return (int) (o1.getPrice() - o2.getPrice());
                            }
                        });
                    }
                    //show all the watches 
                    for (Watch w : sortedWatches) {
                        if (w.getPageId() == pageId && w.getName().toLowerCase().contains(search.toLowerCase())) {
                %>
                <div class="item-list" >
                    <a class="itembox" href="PreviewWatch?watchid=<%= w.getWatchId() - 1%>" id="<%= w.getWatchId()%>">
                        <img class="itemimg" src="images/<%= w.getName()%>.jpg" width="194" height="250"/>
                        <div class="iteminfo">
                            <div class="itemcontent">
                                <h5 class="itemname"><%= w.getName()%></h5>
                                <div class="itemprice">
                                    <strong>$<%= w.getPrice()%></strong>
                                </div>
                            </div>
                        </div>
                    </a>
                </div>
                <%
                            }
                        }
                    }
                %>
            </div>

        </div>
    </body>
</html>
