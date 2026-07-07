//
//  BibleData.swift
//  Bible Chat  ·  "Haven" recreation
//
//  Static content: scripture, journey map, library, chat topics, devotional.
//

import Foundation

enum BibleData {

    // MARK: Verses of the day / paywall
    static let dailyVerse = Verse(
        text: "Jesus Christ is the same yesterday and today and forever",
        reference: "Hebrews 13:8")

    static let paywallVerse = "Psalm 56:3 - When I am afraid, I put my trust in you."

    // MARK: Canonical book list (66 books, KJV chapter counts)
    static let books: [BibleBook] = [
        .init(name: "Genesis", abbreviation: "Gen", chapters: 50, testament: .old),
        .init(name: "Exodus", abbreviation: "Exo", chapters: 40, testament: .old),
        .init(name: "Leviticus", abbreviation: "Lev", chapters: 27, testament: .old),
        .init(name: "Numbers", abbreviation: "Num", chapters: 36, testament: .old),
        .init(name: "Deuteronomy", abbreviation: "Deu", chapters: 34, testament: .old),
        .init(name: "Joshua", abbreviation: "Jos", chapters: 24, testament: .old),
        .init(name: "Judges", abbreviation: "Jdg", chapters: 21, testament: .old),
        .init(name: "Ruth", abbreviation: "Rut", chapters: 4, testament: .old),
        .init(name: "1 Samuel", abbreviation: "1Sa", chapters: 31, testament: .old),
        .init(name: "2 Samuel", abbreviation: "2Sa", chapters: 24, testament: .old),
        .init(name: "1 Kings", abbreviation: "1Ki", chapters: 22, testament: .old),
        .init(name: "2 Kings", abbreviation: "2Ki", chapters: 25, testament: .old),
        .init(name: "1 Chronicles", abbreviation: "1Ch", chapters: 29, testament: .old),
        .init(name: "2 Chronicles", abbreviation: "2Ch", chapters: 36, testament: .old),
        .init(name: "Ezra", abbreviation: "Ezr", chapters: 10, testament: .old),
        .init(name: "Nehemiah", abbreviation: "Neh", chapters: 13, testament: .old),
        .init(name: "Esther", abbreviation: "Est", chapters: 10, testament: .old),
        .init(name: "Job", abbreviation: "Job", chapters: 42, testament: .old),
        .init(name: "Psalms", abbreviation: "Psa", chapters: 150, testament: .old),
        .init(name: "Proverbs", abbreviation: "Pro", chapters: 31, testament: .old),
        .init(name: "Ecclesiastes", abbreviation: "Ecc", chapters: 12, testament: .old),
        .init(name: "Song of Solomon", abbreviation: "Sng", chapters: 8, testament: .old),
        .init(name: "Isaiah", abbreviation: "Isa", chapters: 66, testament: .old),
        .init(name: "Jeremiah", abbreviation: "Jer", chapters: 52, testament: .old),
        .init(name: "Lamentations", abbreviation: "Lam", chapters: 5, testament: .old),
        .init(name: "Ezekiel", abbreviation: "Eze", chapters: 48, testament: .old),
        .init(name: "Daniel", abbreviation: "Dan", chapters: 12, testament: .old),
        .init(name: "Hosea", abbreviation: "Hos", chapters: 14, testament: .old),
        .init(name: "Joel", abbreviation: "Joe", chapters: 3, testament: .old),
        .init(name: "Amos", abbreviation: "Amo", chapters: 9, testament: .old),
        .init(name: "Obadiah", abbreviation: "Oba", chapters: 1, testament: .old),
        .init(name: "Jonah", abbreviation: "Jon", chapters: 4, testament: .old),
        .init(name: "Micah", abbreviation: "Mic", chapters: 7, testament: .old),
        .init(name: "Nahum", abbreviation: "Nah", chapters: 3, testament: .old),
        .init(name: "Habakkuk", abbreviation: "Hab", chapters: 3, testament: .old),
        .init(name: "Zephaniah", abbreviation: "Zep", chapters: 3, testament: .old),
        .init(name: "Haggai", abbreviation: "Hag", chapters: 2, testament: .old),
        .init(name: "Zechariah", abbreviation: "Zec", chapters: 14, testament: .old),
        .init(name: "Malachi", abbreviation: "Mal", chapters: 4, testament: .old),
        .init(name: "Matthew", abbreviation: "Mat", chapters: 28, testament: .new),
        .init(name: "Mark", abbreviation: "Mar", chapters: 16, testament: .new),
        .init(name: "Luke", abbreviation: "Luk", chapters: 24, testament: .new),
        .init(name: "John", abbreviation: "Joh", chapters: 21, testament: .new),
        .init(name: "Acts", abbreviation: "Act", chapters: 28, testament: .new),
        .init(name: "Romans", abbreviation: "Rom", chapters: 16, testament: .new),
        .init(name: "1 Corinthians", abbreviation: "1Co", chapters: 16, testament: .new),
        .init(name: "2 Corinthians", abbreviation: "2Co", chapters: 13, testament: .new),
        .init(name: "Galatians", abbreviation: "Gal", chapters: 6, testament: .new),
        .init(name: "Ephesians", abbreviation: "Eph", chapters: 6, testament: .new),
        .init(name: "Philippians", abbreviation: "Phi", chapters: 4, testament: .new),
        .init(name: "Colossians", abbreviation: "Col", chapters: 4, testament: .new),
        .init(name: "1 Thessalonians", abbreviation: "1Th", chapters: 5, testament: .new),
        .init(name: "2 Thessalonians", abbreviation: "2Th", chapters: 3, testament: .new),
        .init(name: "1 Timothy", abbreviation: "1Ti", chapters: 6, testament: .new),
        .init(name: "2 Timothy", abbreviation: "2Ti", chapters: 4, testament: .new),
        .init(name: "Titus", abbreviation: "Tit", chapters: 3, testament: .new),
        .init(name: "Philemon", abbreviation: "Phm", chapters: 1, testament: .new),
        .init(name: "Hebrews", abbreviation: "Heb", chapters: 13, testament: .new),
        .init(name: "James", abbreviation: "Jas", chapters: 5, testament: .new),
        .init(name: "1 Peter", abbreviation: "1Pe", chapters: 5, testament: .new),
        .init(name: "2 Peter", abbreviation: "2Pe", chapters: 3, testament: .new),
        .init(name: "1 John", abbreviation: "1Jo", chapters: 5, testament: .new),
        .init(name: "2 John", abbreviation: "2Jo", chapters: 1, testament: .new),
        .init(name: "3 John", abbreviation: "3Jo", chapters: 1, testament: .new),
        .init(name: "Jude", abbreviation: "Jud", chapters: 1, testament: .new),
        .init(name: "Revelation", abbreviation: "Rev", chapters: 22, testament: .new),
    ]

    static func book(named name: String) -> BibleBook {
        books.first { $0.name == name } ?? books[0]
    }

    // MARK: Scripture text (KJV) — Genesis 1–3 bundled in full
    static let genesis: [Int: [String]] = [
        1: [
            "In the beginning God created the heaven and the earth.",
            "And the earth was without form, and void; and darkness was upon the face of the deep. And the Spirit of God moved upon the face of the waters.",
            "And God said, Let there be light: and there was light.",
            "And God saw the light, that it was good: and God divided the light from the darkness.",
            "And God called the light Day, and the darkness he called Night. And the evening and the morning were the first day.",
            "And God said, Let there be a firmament in the midst of the waters, and let it divide the waters from the waters.",
            "And God made the firmament, and divided the waters which were under the firmament from the waters which were above the firmament: and it was so.",
            "And God called the firmament Heaven. And the evening and the morning were the second day.",
            "And God said, Let the waters under the heaven be gathered together unto one place, and let the dry land appear: and it was so.",
            "And God called the dry land Earth; and the gathering together of the waters called he Seas: and God saw that it was good.",
            "And God said, Let the earth bring forth grass, the herb yielding seed, and the fruit tree yielding fruit after his kind, whose seed is in itself, upon the earth: and it was so.",
            "And the earth brought forth grass, and herb yielding seed after his kind, and the tree yielding fruit, whose seed was in itself, after his kind: and God saw that it was good.",
            "And the evening and the morning were the third day.",
            "And God said, Let there be lights in the firmament of the heaven to divide the day from the night; and let them be for signs, and for seasons, and for days, and years:",
            "And let them be for lights in the firmament of the heaven to give light upon the earth: and it was so.",
            "And God made two great lights; the greater light to rule the day, and the lesser light to rule the night: he made the stars also.",
            "And God set them in the firmament of the heaven to give light upon the earth,",
            "And to rule over the day and over the night, and to divide the light from the darkness: and God saw that it was good.",
            "And the evening and the morning were the fourth day.",
            "And God said, Let the waters bring forth abundantly the moving creature that hath life, and fowl that may fly above the earth in the open firmament of heaven.",
            "And God created great whales, and every living creature that moveth, which the waters brought forth abundantly, after their kind, and every winged fowl after his kind: and God saw that it was good.",
            "And God blessed them, saying, Be fruitful, and multiply, and fill the waters in the seas, and let fowl multiply in the earth.",
            "And the evening and the morning were the fifth day.",
            "And God said, Let the earth bring forth the living creature after his kind, cattle, and creeping thing, and beast of the earth after his kind: and it was so.",
            "And God made the beast of the earth after his kind, and cattle after their kind, and every thing that creepeth upon the earth after his kind: and God saw that it was good.",
            "And God said, Let us make man in our image, after our likeness: and let them have dominion over the fish of the sea, and over the fowl of the air, and over the cattle, and over all the earth, and over every creeping thing that creepeth upon the earth.",
            "So God created man in his own image, in the image of God created he him; male and female created he them.",
            "And God blessed them, and God said unto them, Be fruitful, and multiply, and replenish the earth, and subdue it: and have dominion over the fish of the sea, and over the fowl of the air, and over every living thing that moveth upon the earth.",
            "And God said, Behold, I have given you every herb bearing seed, which is upon the face of all the earth, and every tree, in the which is the fruit of a tree yielding seed; to you it shall be for meat.",
            "And to every beast of the earth, and to every fowl of the air, and to every thing that creepeth upon the earth, wherein there is life, I have given every green herb for meat: and it was so.",
            "And God saw every thing that he had made, and, behold, it was very good. And the evening and the morning were the sixth day.",
        ],
        2: [
            "Thus the heavens and the earth were finished, and all the host of them.",
            "And on the seventh day God ended his work which he had made; and he rested on the seventh day from all his work which he had made.",
            "And God blessed the seventh day, and sanctified it: because that in it he had rested from all his work which God created and made.",
            "These are the generations of the heavens and of the earth when they were created, in the day that the LORD God made the earth and the heavens,",
            "And every plant of the field before it was in the earth, and every herb of the field before it grew: for the LORD God had not caused it to rain upon the earth, and there was not a man to till the ground.",
            "But there went up a mist from the earth, and watered the whole face of the ground.",
            "And the LORD God formed man of the dust of the ground, and breathed into his nostrils the breath of life; and man became a living soul.",
            "And the LORD God planted a garden eastward in Eden; and there he put the man whom he had formed.",
            "And out of the ground made the LORD God to grow every tree that is pleasant to the sight, and good for food; the tree of life also in the midst of the garden, and the tree of knowledge of good and evil.",
            "And a river went out of Eden to water the garden; and from thence it was parted, and became into four heads.",
        ],
        3: [
            "Now the serpent was more subtil than any beast of the field which the LORD God had made. And he said unto the woman, Yea, hath God said, Ye shall not eat of every tree of the garden?",
            "And the woman said unto the serpent, We may eat of the fruit of the trees of the garden:",
            "But of the fruit of the tree which is in the midst of the garden, God hath said, Ye shall not eat of it, neither shall ye touch it, lest ye die.",
            "And the serpent said unto the woman, Ye shall not surely die:",
            "For God doth know that in the day ye eat thereof, then your eyes shall be opened, and ye shall be as gods, knowing good and evil.",
        ],
    ]

    /// Verses for any book/chapter (Genesis 1–3 real; graceful placeholder otherwise).
    static func verses(book: String, chapter: Int) -> [String] {
        if book == "Genesis", let v = genesis[chapter] { return v }
        return [
            "The reading for \(book) \(chapter) is part of your \(Brand.appName) journey.",
            "Be still, and know that this word is being prepared for you.",
            "Take a breath, and let the quiet ready your heart to receive it.",
            "Every chapter is a doorway; you are always welcome to return.",
        ]
    }

    // MARK: Journey map (streak → postcards)
    static let journeyStops: [JourneyStop] = [
        .init(name: "The Beginning", verse: "In the beginning God created the heaven and the earth.",
              reference: "Genesis 1:1", artwork: .dawn, streaksRequired: 0),
        .init(name: "Garden of Eden", verse: "The Lord God planted a garden eastward in Eden, and there He put the man whom He had formed.",
              reference: "Genesis 2:8", artwork: .garden, streaksRequired: 1),
        .init(name: "Mount Ararat", verse: "And the ark rested in the seventh month, upon the mountains of Ararat.",
              reference: "Genesis 8:4", artwork: .mountains, streaksRequired: 3),
        .init(name: "Bethel", verse: "And he dreamed, and behold a ladder set up on the earth, and the top of it reached to heaven.",
              reference: "Genesis 28:12", artwork: .sunset, streaksRequired: 6),
        .init(name: "Mount Sinai", verse: "And Mount Sinai was altogether on a smoke, because the Lord descended upon it in fire.",
              reference: "Exodus 19:18", artwork: .harvest, streaksRequired: 10),
    ]

    // MARK: Listen library
    static let creationStory = Story(
        title: "Creation: In the Beginning",
        reference: "Genesis 1:1",
        artwork: .darkCreation,
        durationSeconds: 245,
        narration: [
            "The very first sentence of the Bible is also one of its boldest.",
            "No argument, no proof, no build-up — just a statement that reframes everything.",
            "Listen to Genesis chapter one, verse one:",
            "\"In the beginning God created the heavens and the earth.\"",
            "Ten words. And already the Bible has told you who is in charge, when the story starts, and where it's all heading.",
            "But the next verse takes a strange turn:",
            "\"Now the earth was formless and empty.\"",
        ])

    private static func story(_ t: String, _ r: String, _ a: HavenArtwork) -> Story {
        Story(title: t, reference: r, artwork: a, durationSeconds: 200,
              narration: ["A story from \(r).",
                          "Settle in, and let the words find you.",
                          "This is \(t) — read slowly, and listen for the still, small voice."])
    }

    static let libraryCollections: [LibraryCollection] = [
        .init(title: "Bible Stories", artwork: .river, sections: [
            .init(title: "Creation", subtitle: "The beginning of all things and early humanity", stories: [
                creationStory,
                story("Adam and Eve: The Garden Story", "Genesis 2", .garden),
                story("The Adversary", "Genesis 3", .darkCreation),
                story("Cain and Abel", "Genesis 4", .harvest),
                story("Noah and the Flood", "Genesis 6", .mountains),
                story("Noah and the Ark: Hidden in Plain Sight", "Genesis 7", .river),
            ]),
            .init(title: "Patriarchs", subtitle: "Stories of Abraham, Isaac, Jacob, and Joseph", stories: [
                story("Jacob's Ladder", "Genesis 28", .sunset),
                story("Joseph and His Coat of Many Colors", "Genesis 37", .goldenField),
                story("Abraham, Isaac, and Rebekah", "Genesis 24", .village),
                story("Jacob and Esau: A Tale of Two Brothers", "Genesis 27", .harvest),
            ]),
            .init(title: "Exodus", subtitle: "Israel's deliverance from Egypt", stories: [
                story("Moses, the Prince of Egypt", "Exodus 2", .sunset),
                story("The Passover: Exodus 12", "Exodus 12", .darkCreation),
                story("Crossing the Red Sea", "Exodus 14", .river),
                story("The 10 Commandments: Their Real Purpose", "Exodus 20", .mountains),
            ]),
        ]),
        .init(title: "Stories for Men", artwork: .mountains, sections: [
            .init(title: "Courage", subtitle: "Men of conviction", stories: [
                story("David and Goliath", "1 Samuel 17", .harvest),
                story("Daniel in the Lion's Den", "Daniel 6", .darkCreation),
            ]),
        ]),
        .init(title: "Stories for Women", artwork: .waterlilies, sections: [
            .init(title: "Faithfulness", subtitle: "Women of strength", stories: [
                story("Ruth and Naomi", "Ruth 1", .goldenField),
                story("Esther, for Such a Time", "Esther 4", .sunset),
            ]),
        ]),
        .init(title: "By Faith", artwork: .sunset, sections: [
            .init(title: "Hebrews 11", subtitle: "The great cloud of witnesses", stories: [
                story("By Faith, Abraham", "Hebrews 11", .dawn),
            ]),
        ]),
        .init(title: "Daily Reflections", artwork: .dawn, sections: [
            .init(title: "This Week", subtitle: "Short meditations", stories: [
                story("On Being Still", "Psalm 46:10", .river),
            ]),
        ]),
        .init(title: "Today in Christ", artwork: .village, sections: [
            .init(title: "Devotion", subtitle: "Walking with Jesus today", stories: [
                story("The Vine and the Branches", "John 15", .meadow),
            ]),
        ]),
    ]

    // MARK: Chat topics
    static let chatTopics: [ChatTopic] = [
        .init(title: "Ask me anything", artwork: .river,
              prompts: ["How do I start reading the Bible?",
                        "What does grace really mean?",
                        "Help me pray about a decision."]),
        .init(title: "Mental Health", artwork: .mentalHealth,
              prompts: ["I've been feeling anxious.",
                        "How do I find peace when I'm overwhelmed?",
                        "A verse for a hard day?"]),
        .init(title: "Forgiving Others", artwork: .forgiveness,
              prompts: ["How do I forgive someone who hurt me?",
                        "What does the Bible say about forgiveness?"]),
        .init(title: "Serving Others", artwork: .service,
              prompts: ["How can I serve my community?",
                        "What does it mean to love my neighbor?"]),
        .init(title: "Life Changes", artwork: .lifeChange,
              prompts: ["I'm facing a big change.",
                        "How do I trust God with my future?"]),
        .init(title: "Handling Stress", artwork: .stress,
              prompts: ["Everything feels like too much.",
                        "How do I cast my cares on Him?"]),
    ]

    // MARK: Daily devotional (Daily Bread)
    static let dailyBread = Devotional(
        topic: "Daily Bread",
        minutes: 3,
        artwork: .harvest,
        body: """
In Matthew 6:11, Jesus teaches us to pray, 'Give us today our daily bread.' This simple request carries profound wisdom about how we're meant to live—one day at a time, dependent on God's provision. The Israelites learned this lesson in the wilderness when God provided manna that couldn't be hoarded; it had to be gathered fresh each morning.

How often do we exhaust ourselves trying to secure not just today's needs but tomorrow's and next year's as well? We stockpile resources, relationships, and backup plans, as if God might run out of supply. What anxiety could be released if we truly embraced the daily bread mentality?

This doesn't mean we shouldn't plan wisely, but it does challenge the mindset that everything depends on us. God invites us into the freedom of living present-focused, trusting that what we need for this day will be provided. Tomorrow has its own provision waiting.

Take a moment to consider what daily bread looks like for you right now. Is it physical sustenance? Emotional strength? Wisdom for a decision? Whatever you genuinely need for today, ask for it specifically, then open your eyes to see how God provides.
""",
        prayer: """
Heavenly Father, I approach You from a place of neither spiritual high nor low. In this middle ground, teach me to appreciate the value of consistency in my walk with You. Help me to see that faith isn't just about emotional peaks but about the daily choice to trust and follow. May this quiet steadiness become a foundation upon which deeper connection can grow. Amen.
"""
    )
}
