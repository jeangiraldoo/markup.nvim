---Capitalizes the first word in a sentence
---@param sentence string[] List of words forming a sentence
local function capitalize_first_word_in_sentence(sentence)
	local word_to_capitalize = sentence[1]
	local capitalized_word = string.upper(word_to_capitalize:sub(1, 1)) .. word_to_capitalize:sub(2)
	sentence[1] = capitalized_word
end

---Appends a period to the last word in a sentence
---@param sentence string[] List of words forming a sentence
local function append_period_to_last_word(sentence)
	local final_word = sentence[#sentence]
	local final_word_with_dot = final_word .. "."
	sentence[#sentence] = final_word_with_dot
end

---Insert commas into a sentence according to specified limits and probability
---@param sentence string[] List of words forming the sentence
---@param max_commas integer Maximum number of commas allowed in the sentence
---@param comma_chance number Probability (0-1) of inserting a comma after a word
---@return string[] new_sentence A new sentence with commas inserted
local function get_sentence_with_commas(sentence, max_commas, comma_chance)
	local last_word_index = #sentence

	local protected_indexes = {
		1,
		2,
		last_word_index - 1,
		last_word_index,
		last_word_index + 1,
	}

	local sentence_with_commas = {}
	local previous_word_had_comma
	local comma_count = 0

	local function should_insert_comma(random, idx)
		local chance_succeeded = random < comma_chance
		local under_comma_limit = comma_count < max_commas

		return chance_succeeded
			and under_comma_limit
			and not vim.list_contains(protected_indexes, idx)
			and not previous_word_had_comma
	end

	for idx, word in ipairs(sentence) do
		local random_number = math.random()

		if should_insert_comma(random_number, idx) then
			local word_with_comma = word .. ","
			table.insert(sentence_with_commas, word_with_comma)
			previous_word_had_comma = true
			comma_count = comma_count + 1
		else
			previous_word_had_comma = false
			table.insert(sentence_with_commas, word)
		end
	end
	return sentence_with_commas
end

---Generate sentences as word sequences
---
--- Each sentence:
--- - Has a length between "minimum_length" and "maximum_length"
--- - Starts with a capitalized word
--- - May include commas, controlled by "comma_chance" and "max_commas"
--- - Ends with a period
---
---@param number_of_sentences number How many sentences to generate
---@param word_generator fun(length: number): string[] Function that produces a list of words of the given length
---@param sentence_opts { minimum_length: integer, maximum_length: integer, comma_chance: number, max_commas: integer }
---  Options controlling sentence length and punctuation
---@return string[] all_words The generated sequence of words forming the sentences
return function(number_of_sentences, word_generator, sentence_opts)
	local comma_chance, max_commas = sentence_opts.comma_chance, sentence_opts.max_commas
	local all_words = {}

	for _ = 1, number_of_sentences do
		local length = math.random(sentence_opts.minimum_length, sentence_opts.maximum_length)
		local sentence_words = word_generator(length)
		capitalize_first_word_in_sentence(sentence_words)

		local sentence_words_with_commas = get_sentence_with_commas(sentence_words, max_commas, comma_chance)
		append_period_to_last_word(sentence_words_with_commas)

		vim.list_extend(all_words, sentence_words_with_commas)
	end
	return all_words
end
