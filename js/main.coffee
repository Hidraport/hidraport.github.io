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

SlideShow = (config) ->
	return new SlideShow(config) if !( this instanceof SlideShow )
	this.config = config
	this.container = $( this.config.containerSelector )[0]
	return false if not this.container
	this.slides = _ this.container.querySelectorAll this.config.slideSelector
	this.index = 0

SlideShow.prototype =
	select: (index) ->
		return if not this.slides[index]
		this.index = index
		prevIndex = if index is 0 then this.slides.length - 1 else index - 1
		nextIndex = if index is this.slides.length - 1 then 0 else index + 1
		this.prev = this.slides[prevIndex]
		this.next = this.slides[nextIndex]
		this.current = this.slides[this.index]
		this.update()
	update: () ->
		this.slides.forEach (slide) ->
				if slide is this.prev
					slide.classList.add 'prev'
				else
					slide.classList.remove 'prev'
				if slide is this.next
					slide.classList.add 'next'
				else
					slide.classList.remove 'next'
				if slide is this.current
					slide.classList.add 'current'
				else
					slide.classList.remove 'current'
			, this
	goPrev: () ->
		if this.index is 0
			this.select this.slides.length - 1
		else
			this.select this.index - 1
	goNext: () ->
		if this.index is this.slides.length - 1
			this.select 0
		else
			this.select this.index + 1
	play: () ->
		this.select this.index
		this.playingStateID = setInterval this.goNext.bind(this), this.config.interval
	pause: () -> clearInterval this.playingStateID if this.playingStateID

window.SlideShow = SlideShow

scrollToTarget = (target) ->
	scrollTarget = $(target)[0].offsetTop
	scrollToY scrollTarget - 20, 500, 'easeInOutQuint', () -> false

window.scrollToTarget = scrollToTarget

slider = SlideShow
	containerSelector: '.slideshow',
	slideSelector: '.slide',
	interval: 4000

if slider.container
	slider.play()

	slider.container.addEventListener 'mouseover', () ->
		slider.pause()
	slider.container.addEventListener 'mouseout', () ->
		slider.play()

	window.slider = slider



btnContainers = _ $( '.add-button-container' )
tagsContainer = $( '.tags-container' )[0]
formOrcamento = $( '.form-orcamento form' )[0]
if tagsContainer && btnContainers
	tagsContainerLabel = tagsContainer.querySelector '.tags-container-label'
	tagInputs = _ tagsContainer.querySelectorAll '.tag input[type="checkbox"]'
	formTags = if localStorage.getItem('tags') then localStorage.getItem('tags').split '\n' else []

	updateFormTags = () ->
		tagInputs.forEach (input) ->
			input.checked = formTags.indexOf(input.value) >= 0
		if formTags.length
			tagsContainerLabel.innerHTML = 'Produtos: <a href="#tags">' + formTags.length + ' selecionados</a>'
		else
			tagsContainerLabel.innerHTML = 'Produtos: <a href="#tags">nenhum selecionado</a>'

	saveTags = () ->
		localStorage.setItem 'tags', formTags.join '\n'
		updateFormTags()

	addTag = (thisTag) ->
		return if formTags.indexOf(thisTag) >= 0
		formTags.push thisTag
		saveTags()

	removeTag = (thisTag) ->
		index = formTags.indexOf(thisTag)
		if index >= 0
			formTags.splice(index, 1)
			saveTags()

	btnContainers.forEach (item) ->
		item.classList.add 'visible'
		btn = item.querySelector('button.adicionar-produto')
		btn.addEventListener 'click', (e) ->
			addTag(location.pathname)
			scrollToTarget '.form-orcamento'

	updateFormTags()
	tagInputs.forEach (tag) ->
		tag.addEventListener 'change', (e) ->
			if tag.checked
				addTag tag.value
			else
				removeTag tag.value

	tagsContainerLabel.classList.add 'select-style'
	tagsContainer.classList.add 'closed'
	tagsContainerLabel.addEventListener 'click', () ->
		if !(tagsContainer.classList.contains 'closed')
			tagsContainer.classList.add 'closed'
		else
			tagsContainer.classList.remove 'closed'

	formOrcamento.addEventListener 'submit', () ->
		localStorage.clear()
