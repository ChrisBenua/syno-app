import Foundation

/**
 Class for conjugate numerals
 */
class NumbersEndingHelper {
    static func translations(translationsAmount: Int) -> String {
        var translationsEnding = "переводов"
        if (translationsAmount % 10 == 1 && ((translationsAmount) / 10) % 10 != 1) {
            translationsEnding = "перевод"
        }
        if (translationsAmount % 10 >= 2 && translationsAmount % 10 < 5 && ((translationsAmount / 10) % 10 != 1)) {
            translationsEnding = "перевода"
        }
        return translationsEnding
    }
}
