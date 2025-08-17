local sentence_generator = require("markup.lorem.text_types.sentence")

---Generate a series of paragraphs composed of sentences
---
--- Paragraphs are represented as sequences of sentences, with "\n" separating paragraphs
---
---@param number_of_paragraphs number How many paragraphs to generate
---@param word_generator fun(length: number): string[] Function that produces a list of words of the given length
---@param paragraph_opts table Options controlling sentence generation within paragraphs:
---  - sentence_number: number of sentences per paragraph
---  - minimum_sentence_length: minimum number of words per sentence
---  - maximum_sentence_length: maximum number of words per sentence
---  - max_sentence_commas: maximum number of commas per sentence
---  - sentence_comma_chance: probability of a comma appearing after a given word in a sentence
---@return string[] all_sentences Flat list of words forming all sentences of all paragraphs,
--- with "\n" marking paragraph breaks
return function(number_of_paragraphs, word_generator, paragraph_opts)
	local sentences_per_paragraph = paragraph_opts.sentence_number

	local sentence_opts = {
		minimum_length = paragraph_opts.minimum_sentence_length,
		maximum_length = paragraph_opts.maximum_sentence_length,
		max_commas = paragraph_opts.max_sentence_commas,
		comma_chance = paragraph_opts.sentence_comma_chance,
	}

	local all_sentences = {}

	for i = 1, number_of_paragraphs do
		local paragraph_sentences = sentence_generator(sentences_per_paragraph, word_generator, sentence_opts)
		vim.list_extend(all_sentences, paragraph_sentences)

		if i < number_of_paragraphs then
			table.insert(all_sentences, "\n")
		end
	end

	return all_sentences
end
