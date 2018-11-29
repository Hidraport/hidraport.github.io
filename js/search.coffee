---
---

$ = (selector) ->
	document.querySelectorAll(selector)
_ = (nodeList, fn) ->
	if fn
		Array.prototype.map.call(nodeList, fn)
	else
		Array.prototype.slice.call(nodeList)
Element.prototype.prependChild = (child) ->
	this.insertBefore child, this.firstChild


displaySearchResults = ( results, store ) ->
    searchResults = $('#search-results')[0]
    if results.length
        resultsArr = results.map (result) ->
            item = store[result.ref]
            img = if item.type is 'produto' then '<div data-cell="1of4"><img src="' + item.img + '" alt="' + item.title + '"></div>' else ""
            description = if item.content?.trim() then '<p>' + item.content.substring(0, 150) + '... <a href="{{ site.baseurl }}' + item.url + '" data-cell="shrink">Saiba mais</a></p>' else ''
            '<article class="card ' + item.type + '"><div data-grid="center spacing">' + img + '<div data-cell="2of3"><h4><a href="{{ site.baseurl }}' + item.url + '" class="post-title">' + item.title + '</a></h4>' + description + '</div></div>' + item.cta + '</article>'
        searchResults.innerHTML = '<p>Resultados para <strong>' + searchTerm + '</strong></p>' + resultsArr.join ''
    else
        message = document.createElement 'p'
        message.innerHTML = 'Nenhum resultado encontrado para <strong>' + searchTerm + '</strong>.'
        searchResults.prependChild message
    return


_query = (v) ->
    t = window.location.search.substring(1).split '&'
    for q in t
        p = q.split '='
        return decodeURIComponent p[1].replace /\+/g, '%20' if p[0] is v

searchTerm = _query 'q'

if searchTerm
    index = lunr () ->
        @.field 'id'
        @.field 'title', boost: 10
        @.field 'content'
        @.field 'url'
        return

    for id, item of window.store
        index.add
            id:      id
            title:   item.title
            content: item.content
            url:     item.url
    
    results = index.search searchTerm
    ga 'send', 'event', 'Pesquisa', searchTerm, _query 'ref'
    displaySearchResults results, window.store