---
title: News
pageid: news
feed: 1
---

<% n = 1 %>
<% sorted_articles.each do |item| %>
<% if n != featured_count() %>
<div class="main" id="main">
<%= render('/article.*', :item => item, :titleonly => false) %>
</div>
<% n = n + 1 %>
<%end%>
<%end%>
<% if n == featured_count() %>
[See All News Articles »](/articles/)
<%end%>
