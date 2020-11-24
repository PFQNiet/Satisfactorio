local tip = data.raw['tips-and-tricks-item']['introduction']
tip.simulation = {
	init = tiptrickutils..[[
		game.surfaces[1].create_entities_from_blueprint_string{
			string = "0eNq1l92uojAUhd+l1zCBgqC+ysSYClttUlrSljPjGN59NqDEOaBWmvFGAVlfV7v6s6/kIBqoNZeWbK+EF0oasv15JYafJBPdPXupgWwJt1CRgEhWdVfMGKgOAjRpA8JlCb/JNm6Dt+91+lY3hVWPb9J2FxCQllsOA76/uOxlUx2QsY1HARBQWM2LECTo0yXEhoM+sgKQUSuDCkp2dFQNVwG54NcaQSXX+F7/LA3IoTkeQe8N/4OScTR+OgPfyHQkC8VKvDPFZD9uoGwCuvWBamzdWDIjn7yXzz3k01GeyyOX+CgszmDsKxfI60dm+P/egLVcnkz3Pw2V+oJ9g88EdjuU+2508dGRCQMBGW4PI3jjGqtkNzaFarqIYWcHpFJlnyEbCmB9Y8YE7doZFyt3F/n/cgEgMGsnZT29ZKOXCkreVOEY6FqJuRDTfx1J4KfzQTV9+2iym0HkI6IRllfMQmg1k6ZW2oYHEC9HP+0pjzGbIawXEPKPCBsfD9SFEEc+JtwQsY+LxAlBfVy4IZLZ1Xsqm9xl4++y2Ej8zeubRqHBdlG/TbsrKv0CHZoz0yUuiXPTJk59fEZOPlc+ozX1PIfIfFzETi6WzP7oaUfNulj7INxcbGZOGhPRe+CiV3kDWTADJS7eZYPh5UxgE1n1Wfyoz2Lh5JjGHgSnfFP64Tymr7p12BFrwT6dyTRZugNG0w0wm9v/aOqRT6d5TBcsFZ+lIVsOcAuDzyGBOvWRzyHBjbDxGOeOMHcej5Z3vNNumsTLAU6HjoQuB6ycAMlygNPZL0nfFkV3vfxZScTls4LLvZi4Q9YLSglcXaHtqtq+/N0+VNkB+cLiYgj1Ok7zDc3jLM83G9q2fwHfFC06",
			position = {0, 0}
		}
		for _,entity in pairs(game.surfaces[1].find_entities_filtered{name={"constructor","assembler"}}) do
			entity.insert{name="power-shard",count=3}
		end
		io.generate(game.surfaces[1])
	]]
}
