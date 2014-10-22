//
//  SyllableParser.swift
//  Haikyu
//
//  Created by John Nguyen on 15/10/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

struct Component {
	var word: String
	var startIndex: Int
	var endIndex: Int
}

import UIKit

class SyllableParser: NSObject {
	
	
	// NOTE: unordered. Stores Word as key, syllables as value
	var syllablesDictionary: Dictionary<String, Int> = [:]
	// stores words only (use as keys to get syllables
//	var wordComponents: [String] = []
	var wordComponents: [Component] = []
	
	// option, holds all found words, reduces search queries (and lags!)
	var holdWords = true
	
	
	let database = SQLiteDB.sharedInstance()
	let kDictionaryKey = "dictionaries"
	let kWordKey = "word"
	let kSyllablesKey = "syllables"
	
	
	// PARSE WORDS FROM TEXT
	//
	// divides words in given string, gets syllables, stores words
	//
	func parseWordsFromText(text: String) {
		
		// split string at spaces
		var components = componentsFromString(text)
		
		// if words there are stored words
		if !syllablesDictionary.isEmpty {
			
			// to identify what is new and not new
			var newWords: [String] = []
			var existingWords: [String] = []
			
			// word names only, to compare against components
			var wordNames: [String] = Array(syllablesDictionary.keys)
			
			// compare each word
			for index in 0..<components.count {
				
				// if not in store
				if !contains(wordNames, components[index].word) {
					// add to new words
					newWords.append(components[index].word)
					// if already in store
				} else {
					// add to existing
					existingWords.append(components[index].word)
				}
			}
			
			// NOTE: Should at least delete not valid words?
			if !holdWords {
				
				var len = syllablesDictionary.count
				
				// remove old words from store
				for var i = 0; i < len; i++ {
					// if existing doesnt contain word from store
					if !contains(existingWords, wordNames[i]) {
						println("removing: \(wordNames[i])")
						// remove from store
						syllablesDictionary[wordNames[i]] = nil
						// also remove name from list
						wordNames.removeAtIndex(i)
						// adjust index and length (to avoid going out of range)
						i--
						len--
					}
				}
			}
			
			
			// add new words to store
			for word in newWords {
				println("adding: \(word)")
				syllablesDictionary[word] = syllablesForWord(word)
			}
			
		// store is EMPTY but there are components (happens on first letter typed)
		} else if !components.isEmpty {
			println("store is empty, copying")
			// copy
			for component in components {
				// NOTE: is it more efficient to do a multi query rather than many single queries?
				syllablesDictionary[component.word] = syllablesForWord(component.word)
			}
		}
		
		
//		println("components:\(wordComponents), count: \(wordComponents.count), store count: \(syllablesDictionary.count)")
//		println()
//		for word in wordComponents {
//			println("word: \(word), syllables: \(syllablesDictionary[word]!)")
//		}
//		println()
	}
	
	// SPLIT & STRIP STRING, GET INDEXES (start & end in relation to original input text)
	//
	func componentsFromString(text: String) -> [Component] {
		
		// split string at spaces
		var splitWords = text.componentsSeparatedByString(" ")
		
		wordComponents.removeAll(keepCapacity: false)
		
		// GET INDEXES BY COUNTING LENGTH OF WORDS + NO. SPACES
		
		// used to keep track of "position"
		var offset = 0
		
		// get indexes and skip empty elements
		for word in splitWords {
			// extra spaces give empty elements, skip over
			if word.isEmpty {
				offset++
			// find the start & end index for word
			} else {
				
				let component = Component(word: word, startIndex: offset, endIndex: offset + countElements(word) - 1)
				wordComponents.append(component)
				// bump 2 spaces (to next space, then to start of next word)
				offset = component.endIndex + 2
			}
		}

		return wordComponents
	}
	
	
	// COUNT SYLLABLES
	//
	// queries SQL database, returns syllable count (0 if !found)
	//
	func syllablesForWord(word: String) -> Int {
		
		// look up word in dictionary
		var data: [SQLRow] = database.query(generateQueryFor(word))
		
		// success
		if !data.isEmpty {
			
			// note: words are unique
			let row = data.first!
			return row[kSyllablesKey]!.asInt()
			
		} else {
			
			// check for symbols or 's
			if wordEndsInExtraneousCharacter(word) {
				
				// try again
				data = database.query(generateQueryFor(removeExtraneousCharactersFrom(word)))
				
				// sucess
				if !data.isEmpty {
					
					let row = data.first!
					return row[kSyllablesKey]!.asInt()
				}
			}
		}
		
		//println("Word: \(word) not found")
		return 0
	}
	
	
	
	// GENERATE SQL QUERY FOR WORD
	//
	func generateQueryFor(word: String) -> String {
		
		// if single quote, escape
		if wordHasSingleQuote(word) {
			return "SELECT \(kSyllablesKey) FROM dictionary WHERE word LIKE '\(escapeSingleQuoteInWord(word))'"
		} else {
			return "SELECT \(kSyllablesKey) FROM dictionary WHERE word LIKE '\(word)'"
		}
	}
	
	func generateQueryFor(words: Array<String>) -> String {
		
		var query = "SELECT * FROM dictionary WHERE word LIKE "
		
		for index in 0..<words.count {
			
			if wordHasSingleQuote(words[index]) {
				query += "'\(escapeSingleQuoteInWord(words[index]))'"
			} else {
				query += "'\(words[index])'"
			}
			
			// if not last index add OR joiner
			if index != words.count - 1 {
				query += " OR  word LIKE "
			}
		}
		
		return query
	}
	
	// WORD HAS SINGLE QUOTE - (future... deal with double quotes too)
	//
	func wordHasSingleQuote(word: String) -> Bool {
		
		if word.rangeOfString("'") != nil {
			return true
		} else {
			return false
		}
	}
	
	
	// ESCAPE SINGLE QUOTE - in SQL statments, escape with extra single quote
	//
	func escapeSingleQuoteInWord(word: String) -> String {
		
		// check for single quotes at beginning
		let wordAsArray = Array(word)
		
		// if there is text
		if wordAsArray.count > 0 {
			// if first char is a single quote
			if wordAsArray.first! == "'" {
				return "'" + word
				// if last char is a single quote
			} else if wordAsArray.last! == "'" {
				return word + "'"
				
			} else {
				// split word
				let components = word.componentsSeparatedByString("\'")
				let numberOfQuotes = components.count - 1
				
				var joinedWord = components.first!
				// join components
				for index in 0..<numberOfQuotes {
					// append two single quotes and next component
					joinedWord += "''" + "\(components[index + 1])"
				}
				
				return joinedWord
			}
		}
		// no single quote found
		return word
	}
	
	
	// WORD ENDS IN EXTRANEOUS CHARACTER - is this efficient?
	//
	// ending in | 's | ? | ! | , | .
	//
	func wordEndsInExtraneousCharacter(word: String) -> Bool {
		
		let wordAsArray = Array(word)
		
		// symbol
		if wordAsArray.count >= 2 {
			
			let symbols = NSCharacterSet(charactersInString: "?!,.'")
			
			if word.rangeOfCharacterFromSet(symbols) != nil {
				println("Extraneous symbol detected")
				return true
			}
		}
		// possive s
		if (word.rangeOfString("'s") != nil) {
			println("Extraneous symbol detected")
			return true
		} else {
			return false
		}
	}
	
	
	// REMOVE EXTRANEOUS CHARACTERS FROM WORD - ending in | 's | ? | ! | , | .
	//
	// WARNING: if there is a 's, the single quote will have been escaped
	// in preparation for the SQL query, hence there is two to remove not one
	//
	func removeExtraneousCharactersFrom(word: String) -> String {
		
		let wordAsArray = Array(word)
		
		// check for symbols
		if wordAsArray.count >= 2 {
			
			let lastChar = wordAsArray.last!
			
			if lastChar == "?" || lastChar == "!" || lastChar == "," || lastChar == "." || lastChar == "'" {
				return word.componentsSeparatedByString("\(lastChar)").first!
			}
		}
		
		// check for trailing 's
		if wordAsArray.count >= 3 {
			
			// last three are: ''s (note escaped single quote)
			if wordAsArray.last! == "s" && wordAsArray[wordAsArray.count - 2] == "'" && wordAsArray[wordAsArray.count - 3] == "'" {
				
				// strip last three characters
				return word.componentsSeparatedByString("''s").first!
			}
		}
		
		// unchanged
		return word
	}

}
