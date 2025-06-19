local CollectionService = game:GetService("CollectionService")

export type chapter = {
	identifier: string?,
	priority: number?,
	init: (() -> ())?,
	start: (() -> ())?,
	destroy: (() -> ())?,
	[string]: any,
}

export type character = {
	tag: string?,
	priority: number?,
	init: (self: character, instance: Instance) -> ()?,
	start: (self: character) -> ()?,
	destroy: (self: character) -> ()?,
	instance: Instance?,
	[string]: any,
}

export type quill = {
	_chapters: { [string]: chapter },
	_characters: { [string]: { [Instance]: character } },
	_character_definitions: { [string]: character },

	register_chapter: (self: quill, mod: ModuleScript) -> quill,
	register_chapters: (self: quill, container: Folder) -> quill,
	register_character: (self: quill, definition: character) -> quill,
	register_characters: (self: quill, container: Folder) -> quill,
	begin_reading: (self: quill) -> (),
}

local function constructor(): quill
	local self = {} :: quill

	self._chapters = {}
	self._characters = {}
	self._character_definitions = {}

	function self:register_chapter(mod: ModuleScript): quill
		if self._chapters[mod.Name] then
			return self
		end

		local chapterName = mod.Name
		local chapter: chapter = require(mod) :: any
		chapter.identifier = chapter.identifier or chapterName
		chapter.priority = chapter.priority or 1

		local init, start, destroy = chapter.init, chapter.start, chapter.destroy

		assert(not init or typeof(init) == "function", `Chapter {chapterName} init must be a function`)
		assert(not start or typeof(start) == "function", `Chapter {chapterName} start must be a function`)
		assert(
			not destroy or typeof(destroy) == "function",
			`Chapter {chapterName} destroy must be a function`
		)
		assert(typeof(chapter.priority) == "number", `Chapter {chapterName} priority must be a number`)

		self._chapters[chapterName] = chapter
		return self
	end

	function self:register_chapters(container: Folder): quill
		for _, child in container:GetDescendants() do
			if not child:IsA("ModuleScript") then
				continue
			end
			self:register_chapter(child)
		end
		return self
	end

	local function run_chapter_lifecycle(chapters: { chapter }, lifecycle_name: string)
		table.sort(chapters, function(a, b)
			return a.priority > b.priority
		end)
		for _, chapter in chapters do
			local fn = chapter[lifecycle_name]
			if not fn then
				continue
			end
			
			if lifecycle_name == "start" then
				task.spawn(fn, chapter)
			else
				fn(chapter)
			end
		end
	end

	function self:register_character(definition: character): quill
		assert(type(definition.tag) == "string", "Character must have a tag string")
		if self._character_definitions[definition.tag] then
			warn(`Character tag '{definition.tag}' already registered; skipping`)
			return self
		end

		self._character_definitions[definition.tag] = definition
		self._characters[definition.tag] = {}

		local function on_instance_added(instance: Instance)
			local clone = {} :: character
			clone.instance = instance

			for k, v in pairs(definition) do
				clone[k] = v
			end

			self._characters[definition.tag][instance] = clone

			if clone.init then
				clone:init(instance)
			end

			if clone.start then
				task.spawn(clone.start, clone)
			end
		end

		local function on_instance_removed(instance: Instance)
			local char = self._characters[definition.tag][instance]
			if char and char.destroy then
				local ok, err = pcall(char.destroy, char)
				if not ok then
					warn(`[Quill]: Error destroying character {definition.tag}: {err}`)
				end
			end
			self._characters[definition.tag][instance] = nil
		end

		CollectionService:GetInstanceAddedSignal(definition.tag):Connect(on_instance_added)
		CollectionService:GetInstanceRemovedSignal(definition.tag):Connect(on_instance_removed)

		for _, instance in CollectionService:GetTagged(definition.tag) do
			on_instance_added(instance)
		end

		return self
	end

	function self:register_characters(container: Folder): quill
		for _, child in container:GetDescendants() do
			if not child:IsA("ModuleScript") then
				continue
			end
			
			local success, char: character = pcall(require, child)
			if success and char and char.tag then
				self:register_character(char)
			else
				warn(`[Quill]: Failed to load character module '{child.Name}'`)
			end
		end
		return self
	end

	function self:begin_reading()
		local chapter_list = {}
		for _, chapter in self._chapters do
			table.insert(chapter_list, chapter)
		end

		run_chapter_lifecycle(chapter_list, "init")
		run_chapter_lifecycle(chapter_list, "start")

		print(`[Quill]: Loaded {#chapter_list} {(#chapter_list == 1 and "chapter" or "chapters")}.`)
	end

	return self
end

return constructor
