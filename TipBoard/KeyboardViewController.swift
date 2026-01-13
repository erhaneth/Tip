import UIKit

class KeyboardViewController: UIInputViewController {

    // 1. The Brain
    var predictionEngine: PredictionEngine?
    
    // 2. UI Elements
    var suggestionBar: UIStackView!
    var suggestionButtons: [UIButton] = []
    var mainStackView: UIStackView!
    
    // Key Pop-up Preview
    var keyPopupView: UIView?
    var keyPopupLabel: UILabel?
    
    // 3. State Management
    enum KeyboardMode {
        case letters
        case numbers
        case emojis
    }
    var currentMode: KeyboardMode = .letters
    var isUppercase: Bool = false
    var currentEmojiCategory: Int = 0
    var isShowingStickers: Bool = false
    
    // Recently used emojis (loaded from UserDefaults)
    var recentEmojis: [String] = []
    let maxRecentEmojis = 30
    let recentEmojisKey = "RecentlyUsedEmojis"
    
    // Emoji UI Elements
    var emojiContainerView: UIView?
    var emojiCollectionView: UICollectionView?
    var emojiCategoryBar: UIStackView?
    
    // Sticker names (image names in Assets - add your images with these names)
    let stickerNames: [String] = [
        "dan"  // Add your sticker image names here
        // Examples: "saz", "def", "newroz", etc.
    ]
    
    // Emoji Data organized by categories (index 0 is Recent - will be loaded dynamically)
    let emojiCategories: [(icon: String, emojis: [String])] = [
        ("🕐", []), // Recent - loaded dynamically from UserDefaults
        ("😀", ["😀", "😃", "😄", "😁", "😆", "😅", "🤣", "😂", "🙂", "🙃", "😉", "😊", "😇", "🥰", "😍", "🤩", "😘", "😗", "☺️", "😚", "😙", "🥲", "😋", "😛", "😜", "🤪", "😝", "🤑", "🤗", "🤭", "🤫", "🤔", "🤐", "🤨", "😐", "😑", "😶", "😏", "😒", "🙄", "😬", "🤥", "😌", "😔", "😪", "🤤", "😴", "😷", "🤒", "🤕", "🤢", "🤮", "🤧", "🥵", "🥶", "🥴", "😵", "🤯", "🤠", "🥳", "🥸", "😎", "🤓", "🧐", "😕", "😟", "🙁", "☹️", "😮", "😯", "😲", "😳", "🥺", "😦", "😧", "😨", "😰", "😥", "😢", "😭", "😱", "😖", "😣", "😞", "😓", "😩", "😫", "🥱", "😤", "😡", "😠", "🤬", "😈", "👿", "💀", "☠️", "💩", "🤡", "👹", "👺", "👻", "👽", "👾", "🤖"]), // Smileys
        ("🐻", ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐻‍❄️", "🐨", "🐯", "🦁", "🐮", "🐷", "🐽", "🐸", "🐵", "🙈", "🙉", "🙊", "🐒", "🐔", "🐧", "🐦", "🐤", "🐣", "🐥", "🦆", "🦅", "🦉", "🦇", "🐺", "🐗", "🐴", "🦄", "🐝", "🪱", "🐛", "🦋", "🐌", "🐞", "🐜", "🪰", "🪲", "🪳", "🦟", "🦗", "🕷️", "🕸️", "🦂", "🐢", "🐍", "🦎", "🦖", "🦕", "🐙", "🦑", "🦐", "🦞", "🦀", "🐡", "🐠", "🐟", "🐬", "🐳", "🐋", "🦈", "🐊", "🐅", "🐆", "🦓", "🦍", "🦧", "🦣", "🐘", "🦛", "🦏", "🐪", "🐫", "🦒", "🦘", "🦬", "🐃", "🐂", "🐄", "🐎", "🐖", "🐏", "🐑", "🦙", "🐐", "🦌", "🐕", "🐩", "🦮", "🐕‍🦺", "🐈", "🐈‍⬛", "🪶", "🐓", "🦃", "🦤", "🦚", "🦜", "🦢", "🦩", "🕊️", "🐇", "🦝", "🦨", "🦡", "🦫", "🦦", "🦥", "🐁", "🐀", "🐿️", "🦔"]), // Animals
        ("🍔", ["🍏", "🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🫐", "🍈", "🍒", "🍑", "🥭", "🍍", "🥥", "🥝", "🍅", "🍆", "🥑", "🥦", "🥬", "🥒", "🌶️", "🫑", "🌽", "🥕", "🫒", "🧄", "🧅", "🥔", "🍠", "🥐", "🥯", "🍞", "🥖", "🥨", "🧀", "🥚", "🍳", "🧈", "🥞", "🧇", "🥓", "🥩", "🍗", "🍖", "🦴", "🌭", "🍔", "🍟", "🍕", "🫓", "🥪", "🥙", "🧆", "🌮", "🌯", "🫔", "🥗", "🥘", "🫕", "🍝", "🍜", "🍲", "🍛", "🍣", "🍱", "🥟", "🦪", "🍤", "🍙", "🍚", "🍘", "🍥", "🥠", "🥮", "🍢", "🍡", "🍧", "🍨", "🍦", "🥧", "🧁", "🍰", "🎂", "🍮", "🍭", "🍬", "🍫", "🍿", "🍩", "🍪", "🌰", "🥜", "🍯", "🥛", "🍼", "🫖", "☕", "🍵", "🧃", "🥤", "🧋", "🍶", "🍺", "🍻", "🥂", "🍷", "🥃", "🍸", "🍹", "🧉", "🍾", "🧊"]), // Food
        ("⚽", ["⚽", "🏀", "🏈", "⚾", "🥎", "🎾", "🏐", "🏉", "🥏", "🎱", "🪀", "🏓", "🏸", "🏒", "🏑", "🥍", "🏏", "🪃", "🥅", "⛳", "🪁", "🏹", "🎣", "🤿", "🥊", "🥋", "🎽", "🛹", "🛼", "🛷", "⛸️", "🥌", "🎿", "⛷️", "🏂", "🪂", "🏋️", "🤼", "🤸", "🤺", "⛹️", "🤾", "🏌️", "🏇", "🧘", "🏄", "🏊", "🤽", "🚣", "🧗", "🚵", "🚴", "🏆", "🥇", "🥈", "🥉", "🏅", "🎖️", "🏵️", "🎗️", "🎫", "🎟️", "🎪", "🎭", "🎨", "🎬", "🎤", "🎧", "🎼", "🎹", "🥁", "🪘", "🎷", "🎺", "🪗", "🎸", "🪕", "🎻", "🎲", "♟️", "🎯", "🎳", "🎮", "🎰", "🧩"]), // Activities
        ("🚗", ["🚗", "🚕", "🚙", "🚌", "🚎", "🏎️", "🚓", "🚑", "🚒", "🚐", "🛻", "🚚", "🚛", "🚜", "🦯", "🦽", "🦼", "🛴", "🚲", "🛵", "🏍️", "🛺", "🚨", "🚔", "🚍", "🚘", "🚖", "🚡", "🚠", "🚟", "🚃", "🚋", "🚞", "🚝", "🚄", "🚅", "🚈", "🚂", "🚆", "🚇", "🚊", "🚉", "✈️", "🛫", "🛬", "🛩️", "💺", "🛰️", "🚀", "🛸", "🚁", "🛶", "⛵", "🚤", "🛥️", "🛳️", "⛴️", "🚢", "⚓", "🪝", "⛽", "🚧", "🚦", "🚥", "🚏", "🗺️", "🗿", "🗽", "🗼", "🏰", "🏯", "🏟️", "🎡", "🎢", "🎠", "⛲", "⛱️", "🏖️", "🏝️", "🏜️", "🌋", "⛰️", "🏔️", "🗻", "🏕️", "⛺", "🛖", "🏠", "🏡", "🏘️", "🏚️", "🏗️", "🏭", "🏢", "🏬", "🏣", "🏤", "🏥", "🏦", "🏨", "🏪", "🏫", "🏩", "💒", "🏛️", "⛪", "🕌", "🕍", "🛕", "🕋", "⛩️", "🛤️", "🛣️", "🗾", "🎑", "🏞️", "🌅", "🌄", "🌠", "🎇", "🎆", "🌇", "🌆", "🏙️", "🌃", "🌌", "🌉", "🌁"]), // Travel
        ("💡", ["⌚", "📱", "📲", "💻", "⌨️", "🖥️", "🖨️", "🖱️", "🖲️", "🕹️", "🗜️", "💽", "💾", "💿", "📀", "📼", "📷", "📸", "📹", "🎥", "📽️", "🎞️", "📞", "☎️", "📟", "📠", "📺", "📻", "🎙️", "🎚️", "🎛️", "🧭", "⏱️", "⏲️", "⏰", "🕰️", "⌛", "⏳", "📡", "🔋", "🔌", "💡", "🔦", "🕯️", "🪔", "🧯", "🛢️", "💸", "💵", "💴", "💶", "💷", "🪙", "💰", "💳", "💎", "⚖️", "🪜", "🧰", "🪛", "🔧", "🔨", "⚒️", "🛠️", "⛏️", "🪚", "🔩", "⚙️", "🪤", "🧱", "⛓️", "🧲", "🔫", "💣", "🧨", "🪓", "🔪", "🗡️", "⚔️", "🛡️", "🚬", "⚰️", "🪦", "⚱️", "🏺", "🔮", "📿", "🧿", "💈", "⚗️", "🔭", "🔬", "🕳️", "🩹", "🩺", "💊", "💉", "🩸", "🧬", "🦠", "🧫", "🧪", "🌡️", "🧹", "🪠", "🧺", "🧻", "🚽", "🚰", "🚿", "🛁", "🛀", "🧼", "🪥", "🪒", "🧽", "🪣", "🧴", "🛎️", "🔑", "🗝️", "🚪", "🪑", "🛋️", "🛏️", "🛌", "🧸", "🪆", "🖼️", "🪞", "🪟", "🛍️", "🛒", "🎁", "🎈", "🎏", "🎀", "🪄", "🪅", "🎊", "🎉", "🎎", "🏮", "🎐", "🧧", "✉️", "📩", "📨", "📧", "💌", "📥", "📤", "📦", "🏷️", "🪧", "📪", "📫", "📬", "📭", "📮", "📯", "📜", "📃", "📄", "📑", "🧾", "📊", "📈", "📉", "🗒️", "🗓️", "📆", "📅", "🗑️", "📇", "🗃️", "🗳️", "🗄️", "📋", "📁", "📂", "🗂️", "🗞️", "📰", "📓", "📔", "📒", "📕", "📗", "📘", "📙", "📚", "📖", "🔖", "🧷", "🔗", "📎", "🖇️", "📐", "📏", "🧮", "📌", "📍", "✂️", "🖊️", "🖋️", "✒️", "🖌️", "🖍️", "📝", "✏️", "🔍", "🔎", "🔏", "🔐", "🔒", "🔓"]), // Objects
        ("❤️", ["❤️", "🧡", "💛", "💚", "💙", "💜", "🖤", "🤍", "🤎", "💔", "❣️", "💕", "💞", "💓", "💗", "💖", "💘", "💝", "💟", "☮️", "✝️", "☪️", "🕉️", "☸️", "✡️", "🔯", "🕎", "☯️", "☦️", "🛐", "⛎", "♈", "♉", "♊", "♋", "♌", "♍", "♎", "♏", "♐", "♑", "♒", "♓", "🆔", "⚛️", "🉑", "☢️", "☣️", "📴", "📳", "🈶", "🈚", "🈸", "🈺", "🈷️", "✴️", "🆚", "💮", "🉐", "㊙️", "㊗️", "🈴", "🈵", "🈹", "🈲", "🅰️", "🅱️", "🆎", "🆑", "🅾️", "🆘", "❌", "⭕", "🛑", "⛔", "📛", "🚫", "💯", "💢", "♨️", "🚷", "🚯", "🚳", "🚱", "🔞", "📵", "🚭", "❗", "❕", "❓", "❔", "‼️", "⁉️", "🔅", "🔆", "〽️", "⚠️", "🚸", "🔱", "⚜️", "🔰", "♻️", "✅", "🈯", "💹", "❇️", "✳️", "❎", "🌐", "💠", "Ⓜ️", "🌀", "💤", "🏧", "🚾", "♿", "🅿️", "🛗", "🈳", "🈂️", "🛂", "🛃", "🛄", "🛅", "🚹", "🚺", "🚼", "⚧️", "🚻", "🚮", "🎦", "📶", "🈁", "🔣", "ℹ️", "🔤", "🔡", "🔠", "🆖", "🆗", "🆙", "🆒", "🆕", "🆓", "0️⃣", "1️⃣", "2️⃣", "3️⃣", "4️⃣", "5️⃣", "6️⃣", "7️⃣", "8️⃣", "9️⃣", "🔟", "🔢", "#️⃣", "*️⃣", "⏏️", "▶️", "⏸️", "⏯️", "⏹️", "⏺️", "⏭️", "⏮️", "⏩", "⏪", "⏫", "⏬", "◀️", "🔼", "🔽", "➡️", "⬅️", "⬆️", "⬇️", "↗️", "↘️", "↙️", "↖️", "↕️", "↔️", "↪️", "↩️", "⤴️", "⤵️", "🔀", "🔁", "🔂", "🔄", "🔃", "🎵", "🎶", "➕", "➖", "➗", "✖️", "🟰", "♾️", "💲", "💱", "™️", "©️", "®️", "👁️‍🗨️", "🔚", "🔙", "🔛", "🔝", "🔜", "〰️", "➰", "➿", "✔️", "☑️", "🔘", "🔴", "🟠", "🟡", "🟢", "🔵", "🟣", "⚫", "⚪", "🟤", "🔺", "🔻", "🔸", "🔹", "🔶", "🔷", "🔳", "🔲", "▪️", "▫️", "◾", "◽", "◼️", "◻️", "🟥", "🟧", "🟨", "🟩", "🟦", "🟪", "⬛", "⬜", "🟫", "🔈", "🔇", "🔉", "🔊", "🔔", "🔕", "📣", "📢", "👁️‍🗨️", "💬", "💭", "🗯️", "♠️", "♣️", "♥️", "♦️", "🃏", "🎴", "🀄", "🕐", "🕑", "🕒", "🕓", "🕔", "🕕", "🕖", "🕗", "🕘", "🕙", "🕚", "🕛", "🕜", "🕝", "🕞", "🕟", "🕠", "🕡", "🕢", "🕣", "🕤", "🕥", "🕦", "🕧"]), // Symbols
        ("🏳️", ["🏳️", "🏴", "🏴‍☠️", "🏁", "🚩", "🎌", "🏳️‍🌈", "🏳️‍⚧️", "🇺🇳", "🇦🇫", "🇦🇱", "🇩🇿", "🇦🇸", "🇦🇩", "🇦🇴", "🇦🇮", "🇦🇶", "🇦🇬", "🇦🇷", "🇦🇲", "🇦🇼", "🇦🇺", "🇦🇹", "🇦🇿", "🇧🇸", "🇧🇭", "🇧🇩", "🇧🇧", "🇧🇾", "🇧🇪", "🇧🇿", "🇧🇯", "🇧🇲", "🇧🇹", "🇧🇴", "🇧🇦", "🇧🇼", "🇧🇷", "🇮🇴", "🇻🇬", "🇧🇳", "🇧🇬", "🇧🇫", "🇧🇮", "🇰🇭", "🇨🇲", "🇨🇦", "🇮🇨", "🇨🇻", "🇧🇶", "🇰🇾", "🇨🇫", "🇹🇩", "🇨🇱", "🇨🇳", "🇨🇽", "🇨🇨", "🇨🇴", "🇰🇲", "🇨🇬", "🇨🇩", "🇨🇰", "🇨🇷", "🇨🇮", "🇭🇷", "🇨🇺", "🇨🇼", "🇨🇾", "🇨🇿", "🇩🇰", "🇩🇯", "🇩🇲", "🇩🇴", "🇪🇨", "🇪🇬", "🇸🇻", "🇬🇶", "🇪🇷", "🇪🇪", "🇸🇿", "🇪🇹", "🇪🇺", "🇫🇰", "🇫🇴", "🇫🇯", "🇫🇮", "🇫🇷", "🇬🇫", "🇵🇫", "🇹🇫", "🇬🇦", "🇬🇲", "🇬🇪", "🇩🇪", "🇬🇭", "🇬🇮", "🇬🇷", "🇬🇱", "🇬🇩", "🇬🇵", "🇬🇺", "🇬🇹", "🇬🇬", "🇬🇳", "🇬🇼", "🇬🇾", "🇭🇹", "🇭🇳", "🇭🇰", "🇭🇺", "🇮🇸", "🇮🇳", "🇮🇩", "🇮🇷", "🇮🇶", "🇮🇪", "🇮🇲", "🇮🇱", "🇮🇹", "🇯🇲", "🇯🇵", "🎌", "🇯🇪", "🇯🇴", "🇰🇿", "🇰🇪", "🇰🇮", "🇽🇰", "🇰🇼", "🇰🇬", "🇱🇦", "🇱🇻", "🇱🇧", "🇱🇸", "🇱🇷", "🇱🇾", "🇱🇮", "🇱🇹", "🇱🇺", "🇲🇴", "🇲🇬", "🇲🇼", "🇲🇾", "🇲🇻", "🇲🇱", "🇲🇹", "🇲🇭", "🇲🇶", "🇲🇷", "🇲🇺", "🇾🇹", "🇲🇽", "🇫🇲", "🇲🇩", "🇲🇨", "🇲🇳", "🇲🇪", "🇲🇸", "🇲🇦", "🇲🇿", "🇲🇲", "🇳🇦", "🇳🇷", "🇳🇵", "🇳🇱", "🇳🇨", "🇳🇿", "🇳🇮", "🇳🇪", "🇳🇬", "🇳🇺", "🇳🇫", "🇰🇵", "🇲🇰", "🇲🇵", "🇳🇴", "🇴🇲", "🇵🇰", "🇵🇼", "🇵🇸", "🇵🇦", "🇵🇬", "🇵🇾", "🇵🇪", "🇵🇭", "🇵🇳", "🇵🇱", "🇵🇹", "🇵🇷", "🇶🇦", "🇷🇪", "🇷🇴", "🇷🇺", "🇷🇼", "🇼🇸", "🇸🇲", "🇸🇹", "🇸🇦", "🇸🇳", "🇷🇸", "🇸🇨", "🇸🇱", "🇸🇬", "🇸🇽", "🇸🇰", "🇸🇮", "🇬🇸", "🇸🇧", "🇸🇴", "🇿🇦", "🇰🇷", "🇸🇸", "🇪🇸", "🇱🇰", "🇧🇱", "🇸🇭", "🇰🇳", "🇱🇨", "🇵🇲", "🇻🇨", "🇸🇩", "🇸🇷", "🇸🇪", "🇨🇭", "🇸🇾", "🇹🇼", "🇹🇯", "🇹🇿", "🇹🇭", "🇹🇱", "🇹🇬", "🇹🇰", "🇹🇴", "🇹🇹", "🇹🇳", "🇹🇷", "🇹🇲", "🇹🇨", "🇹🇻", "🇻🇮", "🇺🇬", "🇺🇦", "🇦🇪", "🇬🇧", "🏴󠁧󠁢󠁥󠁮󠁧󠁿", "🏴󠁧󠁢󠁳󠁣󠁴󠁿", "🏴󠁧󠁢󠁷󠁬󠁳󠁿", "🇺🇸", "🇺🇾", "🇺🇿", "🇻🇺", "🇻🇦", "🇻🇪", "🇻🇳", "🇼🇫", "🇪🇭", "🇾🇪", "🇿🇲", "🇿🇼"]), // Flags
        ("👋", ["👋", "🤚", "🖐️", "✋", "🖖", "👌", "🤌", "🤏", "✌️", "🤞", "🤟", "🤘", "🤙", "👈", "👉", "👆", "🖕", "👇", "☝️", "👍", "👎", "✊", "👊", "🤛", "🤜", "👏", "🙌", "👐", "🤲", "🤝", "🙏", "✍️", "💅", "🤳", "💪", "🦾", "🦿", "🦵", "🦶", "👂", "🦻", "👃", "🧠", "🫀", "🫁", "🦷", "🦴", "👀", "👁️", "👅", "👄", "👶", "🧒", "👦", "👧", "🧑", "👱", "👨", "🧔", "👩", "🧓", "👴", "👵", "🙍", "🙎", "🙅", "🙆", "💁", "🙋", "🧏", "🙇", "🤦", "🤷", "👮", "🕵️", "💂", "🥷", "👷", "🤴", "👸", "👳", "👲", "🧕", "🤵", "👰", "🤰", "🤱", "👼", "🎅", "🤶", "🦸", "🦹", "🧙", "🧚", "🧛", "🧜", "🧝", "🧞", "🧟", "💆", "💇", "🚶", "🧍", "🧎", "🏃", "💃", "🕺", "🕴️", "👯", "🧖", "🧗", "🤸", "🏌️", "🏇", "⛷️", "🏂", "🏋️", "🤼", "🤽", "🤾", "🤺", "⛹️", "🏊", "🚣", "🧘", "🛀", "🛌", "👭", "👫", "👬", "💏", "💑", "👪", "👨‍👩‍👦", "👨‍👩‍👧", "👨‍👩‍👧‍👦", "👨‍👩‍👦‍👦", "👨‍👩‍👧‍👧", "👨‍👦", "👨‍👦‍👦", "👨‍👧", "👨‍👧‍👦", "👨‍👧‍👧", "👩‍👦", "👩‍👦‍👦", "👩‍👧", "👩‍👧‍👦", "👩‍👧‍👧", "🗣️", "👤", "👥", "🫂", "👣"]) // People & Hands
    ]
    
    // 4. Layout Definitions
    // LOWERCASE (Standard)
    let keysLower = [
        ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "ê", "û"],
        ["a", "s", "d", "f", "g", "h", "j", "k", "l", "ş", "î"],
        ["z", "x", "c", "v", "b", "n", "m", "ç"]
    ]
    
    // NUMBERS & SYMBOLS (Mapped to match the letter grid size roughly)
    let keysNumbers = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "/"],
        ["@", "#", "$", "&", "(", ")", "'", "\"", ":", ";", "!"],
        ["%", "*", "+", "=", "?", ",", ".", "_"]
    ]
    
    // 5. Colors - Dynamic (Light/Dark mode)
    var isDarkMode: Bool {
        return traitCollection.userInterfaceStyle == .dark
    }
    
    // Light mode colors
    let lightBackground = UIColor.clear  // Transparent to match native iOS keyboard
    let lightKeyNormal = UIColor.white
    let lightKeyFunction = UIColor(red: 172/255, green: 177/255, blue: 185/255, alpha: 1.0)
    let lightKeyShadow = UIColor(red: 136/255, green: 138/255, blue: 142/255, alpha: 1.0)
    let lightTextColor = UIColor.black
    
    // Dark mode colors
    let darkBackground = UIColor.clear  // Transparent to match native iOS keyboard
    let darkKeyNormal = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0)  // #4A4A4A
    let darkKeyFunction = UIColor(red: 49/255, green: 49/255, blue: 49/255, alpha: 1.0)  // Slightly darker
    let darkKeyShadow = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
    let darkTextColor = UIColor.white
    
    // Computed properties for current theme
    var colorBackground: UIColor { isDarkMode ? darkBackground : lightBackground }
    var colorKeyNormal: UIColor { isDarkMode ? darkKeyNormal : lightKeyNormal }
    var colorKeyFunction: UIColor { isDarkMode ? darkKeyFunction : lightKeyFunction }
    var colorKeyShadow: UIColor { isDarkMode ? darkKeyShadow : lightKeyShadow }
    var colorText: UIColor { isDarkMode ? darkTextColor : lightTextColor }
    var colorDivider: UIColor { isDarkMode ? UIColor(white: 0.4, alpha: 1.0) : UIColor(white: 0.7, alpha: 1.0) }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load recently used emojis
        loadRecentEmojis()
        
        // Load Brain
        DispatchQueue.global(qos: .userInitiated).async {
            self.predictionEngine = PredictionEngine()
            // Update predictions as soon as engine is ready
            DispatchQueue.main.async {
                self.updatePredictions()
            }
        }
        
        setupSuggestionBar()
        // Initial Layout
        applyTheme()
        updateKeyboardLayout()
        
        // Register for theme changes (iOS 17+)
        registerTraitChanges()
    }
    
    // MARK: - Recent Emojis
    func loadRecentEmojis() {
        if let saved = UserDefaults.standard.stringArray(forKey: recentEmojisKey) {
            recentEmojis = saved
        }
    }
    
    func saveRecentEmoji(_ emoji: String) {
        // Remove if already exists
        recentEmojis.removeAll { $0 == emoji }
        // Add to front
        recentEmojis.insert(emoji, at: 0)
        // Limit size
        if recentEmojis.count > maxRecentEmojis {
            recentEmojis = Array(recentEmojis.prefix(maxRecentEmojis))
        }
        // Save to UserDefaults
        UserDefaults.standard.set(recentEmojis, forKey: recentEmojisKey)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh predictions when keyboard appears
        applyTheme()
        updatePredictions()
    }
    
    // Handle dark/light mode changes (iOS 17+)
    func registerTraitChanges() {
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
                self.applyTheme()
                self.updateKeyboardLayout()
            }
        }
    }
    
    func applyTheme() {
        view.backgroundColor = colorBackground
        suggestionBar?.backgroundColor = colorBackground
        
        // Update suggestion button colors
        for btn in suggestionButtons {
            btn.setTitleColor(colorText, for: .normal)
        }
        
        // Update divider colors
        for subview in suggestionBar?.subviews ?? [] {
            if subview.tag == 999 { // Divider tag
                subview.backgroundColor = colorDivider
            }
        }
    }
    
    // MARK: - 1. Suggestion Bar
    var suggestionDividers: [UIView] = []
    
    func setupSuggestionBar() {
        suggestionBar = UIStackView()
        suggestionBar.axis = .horizontal
        suggestionBar.distribution = .fill
        suggestionBar.spacing = 0
        suggestionBar.translatesAutoresizingMaskIntoConstraints = false
        suggestionBar.backgroundColor = colorBackground

        for i in 0..<3 {
            // Add button
            var config = UIButton.Configuration.plain()
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)

            let btn = UIButton(configuration: config)
            btn.backgroundColor = .clear
            btn.setTitleColor(colorText, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            btn.isHidden = true
            btn.addTarget(self, action: #selector(suggestionTapped(_:)), for: .touchUpInside)
            suggestionButtons.append(btn)
            suggestionBar.addArrangedSubview(btn)
            
            // Add divider after each button except last
            if i < 2 {
                let divider = UIView()
                divider.backgroundColor = colorDivider
                divider.tag = 999  // Tag for identifying dividers
                divider.translatesAutoresizingMaskIntoConstraints = false
                divider.widthAnchor.constraint(equalToConstant: 1).isActive = true
                divider.isHidden = true
                suggestionDividers.append(divider)
                suggestionBar.addArrangedSubview(divider)
            }
        }
        
        // Make buttons equal width
        if suggestionButtons.count >= 3 {
            suggestionButtons[1].widthAnchor.constraint(equalTo: suggestionButtons[0].widthAnchor).isActive = true
            suggestionButtons[2].widthAnchor.constraint(equalTo: suggestionButtons[0].widthAnchor).isActive = true
        }
        
        view.addSubview(suggestionBar)
        
        NSLayoutConstraint.activate([
            suggestionBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            suggestionBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            suggestionBar.topAnchor.constraint(equalTo: view.topAnchor),
            suggestionBar.heightAnchor.constraint(equalToConstant: 42)
        ])
    }
    
    // MARK: - 2. Layout Engine (Redraws keys based on state)
    func updateKeyboardLayout() {
        // 1. Remove old layouts
        mainStackView?.removeFromSuperview()
        emojiContainerView?.removeFromSuperview()
        
        // Check if emoji mode
        if currentMode == .emojis {
            setupEmojiLayout()
            return
        }
        
        // 2. Determine which keys to show
        var currentKeys: [[String]]
        
        if currentMode == .numbers {
            currentKeys = keysNumbers
        } else {
            // If Uppercase, map everything to uppercase
            if isUppercase {
                currentKeys = keysLower.map { row in row.map { $0.uppercased() } }
            } else {
                currentKeys = keysLower
            }
        }
        
        // 3. Build Stack
        mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 12
        mainStackView.distribution = .fillEqually
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // --- ROWS 1, 2, 3 ---
        for (rowIndex, rowKeys) in currentKeys.enumerated() {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 6
            rowStack.distribution = .fillEqually
            
            // Row 3 Special Logic (Shift/Back)
            if rowIndex == 2 {
                // LEFT SIDE FUNCTION KEY
                if currentMode == .letters {
                    // Show SHIFT
                    let shiftTitle = isUppercase ? "⬆" : "⇧" // Filled arrow if active
                    let shiftBtn = createKeyButton(title: shiftTitle, isFunctionKey: true)
                    // Highlight shift if active
                    if isUppercase {
                        shiftBtn.backgroundColor = isDarkMode ? .white : .white
                        shiftBtn.setTitleColor(isDarkMode ? .black : .black, for: .normal)
                    }
                    shiftBtn.addTarget(self, action: #selector(shiftTapped), for: .touchUpInside)
                    rowStack.addArrangedSubview(shiftBtn)
                } else {
                    // Show SYMBOLS Toggle (Simplified: Just a placeholder or specific symbol logic)
                    // For now, we keep it aligned with letters, maybe add a specific symbol key later
                    // Let's put a placeholder spacer to keep alignment or more symbols
                    let spacer = createKeyButton(title: "#+=", isFunctionKey: true)
                     // (Action not implemented for brevity, acts as spacer)
                    rowStack.addArrangedSubview(spacer)
                }
                
                // CENTER KEYS
                for key in rowKeys {
                    let keyBtn = createKeyButton(title: key, isFunctionKey: false)
                    rowStack.addArrangedSubview(keyBtn)
                }
                
                // RIGHT SIDE: Backspace
                let backspaceBtn = createKeyButton(title: "⌫", isFunctionKey: true)
                backspaceBtn.removeTarget(nil, action: nil, for: .allEvents)
                backspaceBtn.addTarget(self, action: #selector(backspaceTapped), for: .touchUpInside)
                rowStack.addArrangedSubview(backspaceBtn)
                
                mainStackView.addArrangedSubview(rowStack)
            } else {
                // Standard Rows 1 & 2
                for key in rowKeys {
                    let keyBtn = createKeyButton(title: key, isFunctionKey: false)
                    rowStack.addArrangedSubview(keyBtn)
                }
                mainStackView.addArrangedSubview(rowStack)
            }
        }
        
        // --- ROW 4 (Bottom) ---
        let bottomRow = UIStackView()
        bottomRow.axis = .horizontal
        bottomRow.spacing = 6
        bottomRow.distribution = .fillProportionally

        // 123 / ABC Button
        let modeTitle = (currentMode == .letters) ? "123" : "ABC"
        let modeBtn = createKeyButton(title: modeTitle, isFunctionKey: true)
        modeBtn.widthAnchor.constraint(equalToConstant: 75).isActive = true
        modeBtn.addTarget(self, action: #selector(modeTapped), for: .touchUpInside)

        // Emoji Button (switches to next keyboard/emoji)
        let emojiBtn = createKeyButton(title: "😊", isFunctionKey: true)
        emojiBtn.removeTarget(nil, action: nil, for: .allEvents)
        emojiBtn.addTarget(self, action: #selector(emojiTapped), for: .touchUpInside)
        emojiBtn.widthAnchor.constraint(equalToConstant: 45).isActive = true

        // Space (Navber) - Make it larger and more prominent
        let spaceBtn = createKeyButton(title: "Navber", isFunctionKey: false)
        spaceBtn.addTarget(self, action: #selector(spaceTapped), for: .touchUpInside)
        spaceBtn.heightAnchor.constraint(equalToConstant: 48).isActive = true

        // Return
        let returnBtn = createKeyButton(title: "⏎", isFunctionKey: true)
        returnBtn.widthAnchor.constraint(equalToConstant: 75).isActive = true
        returnBtn.addTarget(self, action: #selector(returnTapped), for: .touchUpInside)

        bottomRow.addArrangedSubview(modeBtn)
        bottomRow.addArrangedSubview(emojiBtn)
        bottomRow.addArrangedSubview(spaceBtn)
        bottomRow.addArrangedSubview(returnBtn)

        // Set minimum height for bottom row to make spacebar more prominent
        bottomRow.heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
        
        mainStackView.addArrangedSubview(bottomRow)
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 3),
            mainStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -3),
            mainStackView.topAnchor.constraint(equalTo: suggestionBar.bottomAnchor, constant: 8),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -4)
        ])
    }
    
    // MARK: - Emoji Layout
    func setupEmojiLayout() {
        // Hide suggestion bar in emoji mode to get more space
        suggestionBar.isHidden = true
        
        // Container for emoji view
        emojiContainerView = UIView()
        emojiContainerView!.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emojiContainerView!)
        
        // Create collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 6
        let itemSize: CGFloat = 44
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.sectionInset = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        
        // Create collection view
        emojiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        emojiCollectionView!.translatesAutoresizingMaskIntoConstraints = false
        emojiCollectionView!.backgroundColor = .clear
        emojiCollectionView!.delegate = self
        emojiCollectionView!.dataSource = self
        emojiCollectionView!.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        emojiCollectionView!.register(StickerCell.self, forCellWithReuseIdentifier: "StickerCell")
        emojiCollectionView!.showsVerticalScrollIndicator = true
        emojiContainerView!.addSubview(emojiCollectionView!)
        
        // Create category bar
        emojiCategoryBar = UIStackView()
        emojiCategoryBar!.axis = .horizontal
        emojiCategoryBar!.distribution = .fillEqually
        emojiCategoryBar!.spacing = 2
        emojiCategoryBar!.translatesAutoresizingMaskIntoConstraints = false
        emojiContainerView!.addSubview(emojiCategoryBar!)
        
        // Add ABC button first
        let abcBtn = UIButton(type: .system)
        abcBtn.setTitle("ABC", for: .normal)
        abcBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        abcBtn.setTitleColor(colorText, for: .normal)
        abcBtn.backgroundColor = colorKeyFunction
        abcBtn.layer.cornerRadius = 5
        abcBtn.addTarget(self, action: #selector(exitEmojiMode), for: .touchUpInside)
        emojiCategoryBar!.addArrangedSubview(abcBtn)
        
        // Add Stickers button (🖼️ icon)
        let stickersBtn = UIButton(type: .system)
        stickersBtn.setTitle("🖼️", for: .normal)
        stickersBtn.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        stickersBtn.tag = -1 // Special tag for stickers
        stickersBtn.addTarget(self, action: #selector(stickerCategoryTapped), for: .touchUpInside)
        if isShowingStickers {
            stickersBtn.backgroundColor = isDarkMode ? UIColor(white: 0.3, alpha: 1.0) : UIColor(white: 0.85, alpha: 1.0)
            stickersBtn.layer.cornerRadius = 5
        }
        emojiCategoryBar!.addArrangedSubview(stickersBtn)
        
        // Add category buttons
        for (index, category) in emojiCategories.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle(category.icon, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 22)
            btn.tag = index
            btn.addTarget(self, action: #selector(emojiCategoryTapped(_:)), for: .touchUpInside)
            
            // Highlight current category
            if index == currentEmojiCategory && !isShowingStickers {
                btn.backgroundColor = isDarkMode ? UIColor(white: 0.3, alpha: 1.0) : UIColor(white: 0.85, alpha: 1.0)
                btn.layer.cornerRadius = 5
            }
            
            emojiCategoryBar!.addArrangedSubview(btn)
        }
        
        // Add backspace button at the end
        let backspaceBtn = UIButton(type: .system)
        backspaceBtn.setTitle("⌫", for: .normal)
        backspaceBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        backspaceBtn.setTitleColor(colorText, for: .normal)
        backspaceBtn.backgroundColor = colorKeyFunction
        backspaceBtn.layer.cornerRadius = 5
        backspaceBtn.addTarget(self, action: #selector(backspaceTapped), for: .touchUpInside)
        emojiCategoryBar!.addArrangedSubview(backspaceBtn)
        
        // Layout constraints - use view.topAnchor since suggestion bar is hidden
        NSLayoutConstraint.activate([
            emojiContainerView!.leftAnchor.constraint(equalTo: view.leftAnchor),
            emojiContainerView!.rightAnchor.constraint(equalTo: view.rightAnchor),
            emojiContainerView!.topAnchor.constraint(equalTo: view.topAnchor),
            emojiContainerView!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            emojiContainerView!.heightAnchor.constraint(greaterThanOrEqualToConstant: 220),
            
            emojiCategoryBar!.leftAnchor.constraint(equalTo: emojiContainerView!.leftAnchor, constant: 4),
            emojiCategoryBar!.rightAnchor.constraint(equalTo: emojiContainerView!.rightAnchor, constant: -4),
            emojiCategoryBar!.bottomAnchor.constraint(equalTo: emojiContainerView!.bottomAnchor, constant: -4),
            emojiCategoryBar!.heightAnchor.constraint(equalToConstant: 42),
            
            emojiCollectionView!.leftAnchor.constraint(equalTo: emojiContainerView!.leftAnchor),
            emojiCollectionView!.rightAnchor.constraint(equalTo: emojiContainerView!.rightAnchor),
            emojiCollectionView!.topAnchor.constraint(equalTo: emojiContainerView!.topAnchor),
            emojiCollectionView!.bottomAnchor.constraint(equalTo: emojiCategoryBar!.topAnchor, constant: -4),
            emojiCollectionView!.heightAnchor.constraint(greaterThanOrEqualToConstant: 160)
        ])
        
        // Force layout and reload data
        view.layoutIfNeeded()
        emojiCollectionView!.reloadData()
    }
    
    @objc func emojiCategoryTapped(_ sender: UIButton) {
        isShowingStickers = false
        currentEmojiCategory = sender.tag
        emojiCollectionView?.reloadData()
        emojiCollectionView?.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        
        // Update category bar highlighting
        updateKeyboardLayout()
    }
    
    @objc func stickerCategoryTapped() {
        isShowingStickers = true
        emojiCollectionView?.reloadData()
        if stickerNames.count > 0 {
            emojiCollectionView?.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
        
        // Update category bar highlighting
        updateKeyboardLayout()
    }
    
    @objc func exitEmojiMode() {
        suggestionBar.isHidden = false
        isShowingStickers = false
        currentMode = .letters
        updateKeyboardLayout()
    }
    
    // MARK: - Sticker Handling
    func insertSticker(_ stickerName: String) {
        guard let image = UIImage(named: stickerName) else { return }
        
        // Check if we have Full Access
        if canAccessClipboard {
            // Copy image to clipboard
            UIPasteboard.general.image = image
            
            // Show feedback
            showStickerCopiedFeedback()
        } else {
            // Prompt user to enable Full Access
            showFullAccessPrompt()
        }
    }
    
    func showStickerCopiedFeedback() {
        let feedbackLabel = UILabel()
        feedbackLabel.text = "Copied! Paste to share"
        feedbackLabel.textColor = .white
        feedbackLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        feedbackLabel.textAlignment = .center
        feedbackLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        feedbackLabel.layer.cornerRadius = 8
        feedbackLabel.clipsToBounds = true
        feedbackLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(feedbackLabel)
        NSLayoutConstraint.activate([
            feedbackLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feedbackLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            feedbackLabel.widthAnchor.constraint(equalToConstant: 180),
            feedbackLabel.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // Animate and remove
        UIView.animate(withDuration: 0.3, delay: 1.5, options: [], animations: {
            feedbackLabel.alpha = 0
        }, completion: { _ in
            feedbackLabel.removeFromSuperview()
        })
    }
    
    func showFullAccessPrompt() {
        let feedbackLabel = UILabel()
        feedbackLabel.text = "Enable Full Access in Settings"
        feedbackLabel.textColor = .white
        feedbackLabel.backgroundColor = UIColor.systemOrange
        feedbackLabel.textAlignment = .center
        feedbackLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        feedbackLabel.layer.cornerRadius = 8
        feedbackLabel.clipsToBounds = true
        feedbackLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(feedbackLabel)
        NSLayoutConstraint.activate([
            feedbackLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feedbackLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            feedbackLabel.widthAnchor.constraint(equalToConstant: 250),
            feedbackLabel.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        UIView.animate(withDuration: 0.3, delay: 2.0, options: [], animations: {
            feedbackLabel.alpha = 0
        }, completion: { _ in
            feedbackLabel.removeFromSuperview()
        })
    }
    
    var canAccessClipboard: Bool {
        return isOpenAccessGranted
    }
    
    var isOpenAccessGranted: Bool {
        // Check if we can write to pasteboard (indicates Full Access)
        let testString = UUID().uuidString
        UIPasteboard.general.string = testString
        let canWrite = UIPasteboard.general.string == testString
        if canWrite {
            UIPasteboard.general.string = ""
        }
        return canWrite
    }
    
    // MARK: - 3. Styling Engine
    func createKeyButton(title: String, isFunctionKey: Bool) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.backgroundColor = isFunctionKey ? colorKeyFunction : colorKeyNormal
        btn.setTitleColor(colorText, for: .normal)
        btn.layer.shadowColor = colorKeyShadow.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        btn.layer.shadowOpacity = isDarkMode ? 0.5 : 1.0
        btn.layer.shadowRadius = 0.0
        btn.layer.masksToBounds = false
        btn.layer.cornerRadius = 5.0
        
        if title.count > 1 {
             btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        } else {
             btn.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .light)
        }

        // Auto-add action for standard keys (single character keys)
        if !["⌫", "Navber", "⏎", "123", "ABC", "⇧", "⬆", "#+="].contains(title) {
            btn.addTarget(self, action: #selector(keyTouchDown(_:)), for: .touchDown)
            btn.addTarget(self, action: #selector(keyTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        }
        return btn
    }
    
    // MARK: - Key Pop-up Preview
    func showKeyPopup(for button: UIButton, character: String) {
        // Remove existing popup
        hideKeyPopup()
        
        // Create popup container
        let popupWidth: CGFloat = 56
        let popupHeight: CGFloat = 76
        let bubbleTailHeight: CGFloat = 10
        
        let popup = UIView()
        popup.backgroundColor = .clear
        popup.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the bubble shape - matches theme
        let bubbleView = UIView()
        bubbleView.backgroundColor = isDarkMode ? UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0) : .white
        bubbleView.layer.cornerRadius = 9
        bubbleView.layer.shadowColor = UIColor.black.cgColor
        bubbleView.layer.shadowOffset = CGSize(width: 0, height: 2)
        bubbleView.layer.shadowOpacity = isDarkMode ? 0.5 : 0.3
        bubbleView.layer.shadowRadius = 4
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        popup.addSubview(bubbleView)
        
        // Create the label - matches theme
        let label = UILabel()
        label.text = character
        label.font = UIFont.systemFont(ofSize: 36, weight: .light)
        label.textColor = isDarkMode ? .white : .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(label)
        
        // Add to view hierarchy (above everything)
        view.addSubview(popup)
        
        // Position popup above the key
        let buttonFrame = button.convert(button.bounds, to: view)
        
        NSLayoutConstraint.activate([
            // Bubble constraints
            bubbleView.topAnchor.constraint(equalTo: popup.topAnchor),
            bubbleView.centerXAnchor.constraint(equalTo: popup.centerXAnchor),
            bubbleView.widthAnchor.constraint(equalToConstant: popupWidth),
            bubbleView.heightAnchor.constraint(equalToConstant: popupHeight - bubbleTailHeight),
            
            // Label constraints
            label.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
            
            // Popup position
            popup.centerXAnchor.constraint(equalTo: view.leftAnchor, constant: buttonFrame.midX),
            popup.bottomAnchor.constraint(equalTo: view.topAnchor, constant: buttonFrame.minY + 4),
            popup.widthAnchor.constraint(equalToConstant: popupWidth),
            popup.heightAnchor.constraint(equalToConstant: popupHeight)
        ])
        
        keyPopupView = popup
        keyPopupLabel = label
        
        // Animate in
        popup.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        popup.alpha = 0
        UIView.animate(withDuration: 0.1) {
            popup.transform = .identity
            popup.alpha = 1
        }
    }
    
    func hideKeyPopup() {
        if let popup = keyPopupView {
            UIView.animate(withDuration: 0.08, animations: {
                popup.alpha = 0
            }) { _ in
                popup.removeFromSuperview()
            }
            keyPopupView = nil
            keyPopupLabel = nil
        }
    }
    
    @objc func keyTouchDown(_ sender: UIButton) {
        guard let title = sender.title(for: .normal), title.count == 1 else { return }
        showKeyPopup(for: sender, character: title)
    }
    
    @objc func keyTouchUp(_ sender: UIButton) {
        hideKeyPopup()
        
        // Actually insert the character
        guard let letter = sender.title(for: .normal) else { return }
        textDocumentProxy.insertText(letter)
        UIDevice.current.playInputClick()
        
        // Update predictions immediately after typing
        updatePredictions()
        
        // Auto-lowercase after typing a letter (standard behavior)
        if isUppercase {
            isUppercase = false
            updateKeyboardLayout()
        }
    }
    
    // MARK: - Actions
    
    @objc func shiftTapped() {
        isUppercase.toggle()
        updateKeyboardLayout() // Re-draw keys
    }
    
    @objc func modeTapped() {
        if currentMode == .letters {
            currentMode = .numbers
        } else {
            currentMode = .letters
        }
        updateKeyboardLayout() // Re-draw keys
    }
    
    @objc func emojiTapped() {
        // Switch to emoji keyboard mode
        currentMode = .emojis
        currentEmojiCategory = 1 // Start with smileys (index 1, since 0 is recent)
        updateKeyboardLayout()
    }
    
    @objc func spaceTapped() {
        // Auto-correction disabled - suggestions shown in bar only
        // performAutocorrect()
        textDocumentProxy.insertText(" ")
        updatePredictions()
    }
    
    @objc func backspaceTapped() {
        textDocumentProxy.deleteBackward()
        updatePredictions()
    }
    
    @objc func returnTapped() {
        // Auto-correction disabled - suggestions shown in bar only
        // performAutocorrect()
        textDocumentProxy.insertText("\n")
        updatePredictions()
    }
    
    // MARK: - Autocorrect Logic
    
    /// Performs autocorrect on the current word before inserting space/punctuation
    func performAutocorrect() {
        guard let engine = predictionEngine else { return }
        
        // Get the current word being typed
        guard let currentWord = getCurrentWord(), !currentWord.isEmpty else { return }
        
        // Check if we have a correction
        if let correction = engine.getCorrection(for: currentWord) {
            // Delete the misspelled word
            for _ in 0..<currentWord.count {
                textDocumentProxy.deleteBackward()
            }
            // Insert the corrected word
            textDocumentProxy.insertText(correction)
            
            print("✨ Autocorrected: '\(currentWord)' → '\(correction)'")
        }
    }
    
    /// Gets the current word being typed (before cursor)
    func getCurrentWord() -> String? {
        guard let context = textDocumentProxy.documentContextBeforeInput else { return nil }
        
        // Find the last word (text after last space/newline)
        let trimmed = context.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return nil }
        
        // Split by whitespace and get the last word
        let words = trimmed.components(separatedBy: .whitespacesAndNewlines)
        return words.last
    }
    
    /// Handler for punctuation keys (suggestions shown in bar only)
    @objc func punctuationTapped(_ sender: UIButton) {
        guard let punctuation = sender.title(for: .normal) else { return }
        // Auto-correction disabled - suggestions shown in bar only
        // performAutocorrect()
        textDocumentProxy.insertText(punctuation)
        UIDevice.current.playInputClick()
        updatePredictions()
    }

    @objc func suggestionTapped(_ sender: UIButton) {
        guard var word = sender.title(for: .normal) else { return }
        let proxy = self.textDocumentProxy
        
        // Remove quotes if this is the first button (quoted suggestion)
        if word.hasPrefix("\"") && word.hasSuffix("\"") {
            word = String(word.dropFirst().dropLast())
        }
        
        // Check if user is typing a partial word (no trailing space)
        if let context = proxy.documentContextBeforeInput, !context.hasSuffix(" ") {
            // Delete the partial word first
            if let partialWord = getCurrentWord() {
                for _ in 0..<partialWord.count {
                    proxy.deleteBackward()
                }
            }
        }
        
        // Insert the complete suggestion with a space
        proxy.insertText(word + " ")
        updatePredictions()
    }
    
    // MARK: - Prediction Logic
    override func textDidChange(_ textInput: UITextInput?) {
        updatePredictions()
    }
    
    override func selectionWillChange(_ textInput: UITextInput?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.updatePredictions()
        }
    }
    
    func updatePredictions() {
        let proxy = self.textDocumentProxy
        guard let context = proxy.documentContextBeforeInput else {
            updateButtons(typedWord: nil, bestCorrection: nil, nextWords: [])
            return
        }

        DispatchQueue.global(qos: .userInteractive).async {
            guard let engine = self.predictionEngine else { return }

            // Check if user is typing a word (no space at end)
            let isTypingWord = !context.hasSuffix(" ") && !context.hasSuffix("\n")

            var typedWord: String? = nil
            var bestCorrection: String? = nil
            var nextWordPredictions: [String] = []

            if isTypingWord, let currentWord = self.getCurrentWord(), currentWord.count >= 1 {
                typedWord = currentWord

                // Get spelling correction if word is 3+ chars
                if currentWord.count >= 3 {
                    let spellingSuggestions = engine.getSpellingSuggestions(for: currentWord, maxSuggestions: 1)
                    bestCorrection = spellingSuggestions.first
                }

                // Get next-word predictions based on PREVIOUS context (not the partial word)
                // Remove the current partial word to get predictions for what comes AFTER it
                let words = context.components(separatedBy: .whitespacesAndNewlines)
                let previousContext = words.dropLast().joined(separator: " ")
                if !previousContext.isEmpty {
                    nextWordPredictions = engine.getSuggestions(for: previousContext + " ")
                } else {
                    // No previous context - get general predictions
                    nextWordPredictions = engine.getSuggestions(for: " ")
                }
            } else {
                // Not typing - get next-word predictions normally
                nextWordPredictions = engine.getSuggestions(for: context)
            }

            DispatchQueue.main.async {
                self.updateButtons(typedWord: typedWord, bestCorrection: bestCorrection, nextWords: nextWordPredictions)
            }
        }
    }
    
    func updateButtons(typedWord: String?, bestCorrection: String?, nextWords: [String]) {
        // 3-segment layout:
        // Left: Typed word in quotes "word" OR first next-word prediction
        // Center: Best spelling correction (highlighted) OR second next-word prediction
        // Right: Next-word prediction (third or second depending on context)

        var segments: [String] = []
        var centerIsHighlighted = false

        if let typed = typedWord, !typed.isEmpty {
            // User is typing a word

            // Left: Typed word in quotes
            segments.append("\"\(typed)\"")

            // Center: Best correction (if misspelled) OR first next-word prediction
            if let correction = bestCorrection, correction.lowercased() != typed.lowercased() {
                segments.append(correction)
                centerIsHighlighted = true

                // Right: First next-word prediction
                if !nextWords.isEmpty {
                    segments.append(nextWords[0])
                }
            } else {
                // No correction needed - fill with next-word predictions
                // Center: First prediction
                if nextWords.count > 0 {
                    segments.append(nextWords[0])
                }
                // Right: Second prediction
                if nextWords.count > 1 {
                    segments.append(nextWords[1])
                }
            }
        } else {
            // Not typing - show up to 3 next-word predictions
            segments = Array(nextWords.prefix(3))
        }

        // Update buttons
        var visibleCount = 0
        for (index, btn) in suggestionButtons.enumerated() {
            if index < segments.count {
                btn.setTitle(segments[index], for: .normal)

                // Highlight center button if it's a spelling correction (iOS style)
                if centerIsHighlighted && index == 1 && segments.count >= 2 {
                    // Use a more visible iOS-style highlight
                    if isDarkMode {
                        btn.setTitleColor(.white, for: .normal)
                        btn.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
                    } else {
                        btn.setTitleColor(.black, for: .normal)
                        btn.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
                    }
                    btn.layer.cornerRadius = 6
                    btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
                } else {
                    btn.setTitleColor(colorText, for: .normal)
                    btn.backgroundColor = .clear
                    btn.layer.cornerRadius = 0
                    btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                }

                btn.isHidden = false
                visibleCount += 1
            } else {
                btn.isHidden = true
            }
        }

        // Show/hide dividers based on visible buttons
        for (index, divider) in suggestionDividers.enumerated() {
            divider.isHidden = (index + 1 >= visibleCount)
            divider.backgroundColor = colorDivider
        }
    }
}

// MARK: - Emoji Collection View Delegate & DataSource
extension KeyboardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // Helper to get emojis for current category (handles recent emojis)
    func getEmojisForCurrentCategory() -> [String] {
        if currentEmojiCategory == 0 {
            // Recent emojis
            return recentEmojis
        }
        return emojiCategories[currentEmojiCategory].emojis
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isShowingStickers {
            return stickerNames.count
        }
        return getEmojisForCurrentCategory().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isShowingStickers {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickerCell", for: indexPath) as! StickerCell
            let stickerName = stickerNames[indexPath.item]
            cell.configure(with: stickerName)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
            let emojis = getEmojisForCurrentCategory()
            let emoji = emojis[indexPath.item]
            cell.configure(with: emoji)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isShowingStickers {
            let stickerName = stickerNames[indexPath.item]
            insertSticker(stickerName)
        } else {
            let emojis = getEmojisForCurrentCategory()
            let emoji = emojis[indexPath.item]
            textDocumentProxy.insertText(emoji)
            // Save to recent emojis
            saveRecentEmoji(emoji)
        }
    }
}

// MARK: - Emoji Cell
class EmojiCell: UICollectionViewCell {
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with emoji: String) {
        emojiLabel.text = emoji
    }
}

// MARK: - Sticker Cell
class StickerCell: UICollectionViewCell {
    private let stickerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(stickerImageView)
        NSLayoutConstraint.activate([
            stickerImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            stickerImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            stickerImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 2),
            stickerImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -2)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with stickerName: String) {
        stickerImageView.image = UIImage(named: stickerName)
    }
}
