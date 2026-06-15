/// Simple spell checker for English text
class SpellChecker {
  static final Set<String> _commonWords = {
    'the', 'be', 'to', 'of', 'and', 'a', 'in', 'that', 'have', 'i',
    'it', 'for', 'not', 'on', 'with', 'he', 'as', 'you', 'do', 'at',
    'this', 'but', 'his', 'by', 'from', 'they', 'we', 'say', 'her', 'she',
    'an', 'will', 'my', 'one', 'all', 'would', 'there', 'their', 'what',
    'so', 'up', 'out', 'if', 'about', 'who', 'get', 'which', 'go', 'me',
    'when', 'make', 'can', 'like', 'time', 'no', 'just', 'him', 'know', 'take',
    'people', 'into', 'year', 'your', 'good', 'some', 'could', 'them', 'see', 'other',
    'than', 'then', 'now', 'look', 'only', 'come', 'its', 'over', 'think', 'also',
    'back', 'after', 'use', 'two', 'how', 'our', 'work', 'first', 'well', 'way',
    'even', 'new', 'want', 'because', 'any', 'these', 'give', 'day', 'most', 'us',
    'is', 'are', 'was', 'were', 'been', 'has', 'had', 'did', 'does', 'done',
    'markdown', 'editor', 'file', 'save', 'open', 'close', 'edit', 'preview',
    'export', 'import', 'copy', 'paste', 'cut', 'undo', 'redo', 'find', 'replace',
    'bold', 'italic', 'underline', 'heading', 'list', 'table', 'image', 'link',
    'code', 'block', 'quote', 'math', 'formula', 'mermaid', 'diagram', 'chart',
  };

  /// Check if a word is spelled correctly
  static bool isCorrect(String word) {
    if (word.isEmpty) return true;
    
    // Skip numbers, URLs, code, and special characters
    if (RegExp(r'^[\d\W_]+$').hasMatch(word)) return true;
    if (word.startsWith('http') || word.contains('://')) return true;
    if (word.contains('.') || word.contains('/')) return true;
    
    // Convert to lowercase
    final lower = word.toLowerCase();
    
    // Check common words
    if (_commonWords.contains(lower)) return true;
    
    // Check if it's a common word with suffix
    for (final suffix in ['s', 'ed', 'ing', 'ly', 'er', 'est', 'tion', 'ment', 'ness']) {
      if (lower.endsWith(suffix)) {
        final root = lower.substring(0, lower.length - suffix.length);
        if (_commonWords.contains(root)) return true;
      }
    }
    
    // For now, accept words longer than 3 characters that aren't in our dictionary
    // This is a simple heuristic to avoid marking too many words as incorrect
    return lower.length <= 3 || _isLikelyValidWord(lower);
  }

  /// Simple heuristic to check if a word looks valid
  static bool _isLikelyValidWord(String word) {
    // Check for common patterns
    if (RegExp(r'^[a-z]+\$').hasMatch(word)) {
      // Simple word - accept if it has vowels
      return word.contains(RegExp(r'[aeiou]'));
    }
    return true;
  }

  /// Get suggestions for a misspelled word
  static List<String> getSuggestions(String word) {
    if (word.isEmpty) return [];
    
    final lower = word.toLowerCase();
    final suggestions = <String>[];
    
    // Find similar words from dictionary
    for (final dictWord in _commonWords) {
      if (_isSimilar(lower, dictWord)) {
        suggestions.add(dictWord);
        if (suggestions.length >= 5) break;
      }
    }
    
    return suggestions;
  }

  /// Check if two words are similar (simple edit distance)
  static bool _isSimilar(String word1, String word2) {
    if (word1.isEmpty || word2.isEmpty) return false;
    if ((word1.length - word2.length).abs() > 2) return false;
    
    // Simple check: if they share the first 2 characters and similar length
    if (word1.length >= 2 && word2.length >= 2) {
      if (word1.startsWith(word2.substring(0, 2)) || 
          word2.startsWith(word1.substring(0, 2))) {
        return true;
      }
    }
    
    return false;
  }
}