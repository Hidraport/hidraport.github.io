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



formOrcSection = $('.section-orcamento')[0]
tags = if localStorage.tags then JSON.parse localStorage.tags else []

saveTags = () ->
	localStorage.tags = JSON.stringify tags
addTag = (input) ->
	if tags.indexOf(input.value) == -1
		tags.push input.value
		input.check() if input.check
	saveTags()
removeTag = (input) ->
	index = tags.indexOf(input.value)
	if index > -1
		tags.splice index, 1
	input.uncheck() if input.uncheck
	saveTags()

if formOrcSection
	formOrc = formOrcSection.querySelector '.form-orcamento'
	if formOrc
		formOrc.addEventListener 'submit', (e) ->
			localStorage.clear()
		formOrcSection.classList.add 'js'
		btns = _ $('[data-orc-value]')
		btns.forEach (btn) ->
			btn.addEventListener 'click', (e) ->
				tagSelector = btn.getAttribute 'data-orc-value'
				addTag formOrc.querySelector 'input[value="' + tagSelector + '"]'

		tagListContainer = formOrc.querySelector '.orc-produtos-list'
		tagList = _ tagListContainer.querySelectorAll 'li'

		tagSelectLabel = 'Adicionar produtos...'
		tagSelect = document.createElement('select')
		tagSelect.addOption = (val) ->
			newOption = document.createElement('option')
			newOption.text = val
			tagSelect.add newOption
		tagSelect.addOption tagSelectLabel
		tagSelect.addEventListener 'change', (e) ->
			inputSelected = tagListContainer.querySelector 'input[value="' + tagSelect.value + '"]'
			addTag inputSelected if inputSelected
			tagSelect.selectedIndex = 0
		firstTagItem = document.createElement 'li'
		firstTagItem.className = 'first-tag-item'
		firstTagItem.prependChild tagSelect

		tagList.forEach (tag) ->
			input = tag.querySelector 'input.orc-produtos-checkbox'
			label = input.value
			parent = input.parentNode
			tagSelect.addOption input.value
			input.check = () ->
				input.checked = true
				input.parentNode.classList.remove 'unchecked'
				input.parentNode.classList.add 'checked'
			input.uncheck = () ->
				input.checked = false
				input.parentNode.classList.add 'unchecked'
				input.parentNode.classList.remove 'checked'
			if tags.indexOf(label) > -1
				input.check()
			else
				input.uncheck()
			input.addEventListener 'change', (e) ->
				if input.checked
					addTag input
				else
					removeTag input
					# Firefox scroll hack
					tagListContainer.scrollLeft = 0

		tagListContainer.prependChild firstTagItem