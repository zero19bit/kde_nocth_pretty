.pragma library
.import "jalali.js" as Jalali

// Calendar identifiers are persisted: 0 = Jalali, 1 = Gregorian, 2 = Islamic civil.
var names = ["شمسی", "میلادی", "قمری"]
var hijriMonths = ["محرم", "صفر", "ربیع‌الاول", "ربیع‌الثانی", "جمادی‌الاول", "جمادی‌الثانی", "رجب", "شعبان", "رمضان", "شوال", "ذی‌القعده", "ذی‌الحجه"]
var gregorianMonths = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
var gregorianWeekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

function civilToDay(y, m, d) {
    return 1948440 + 354 * (y - 1) + Math.floor((3 + 11 * y) / 30)
           + Math.ceil(29.5 * (m - 1)) + d - 1
}

function dayToCivil(day) {
    var y = Math.floor((30 * (day - 1948440) + 10646) / 10631)
    var m = 1
    while (m < 12 && day >= civilToDay(y, m + 1, 1)) m++
    return { y: y, m: m, d: day - civilToDay(y, m, 1) + 1 }
}

function parts(date, type, adjustment) {
    if (type === 0) {
        var j = Jalali.toJalali(date)
        return { y: j.jy, m: j.jm, d: j.jd }
    }
    if (type === 2) {
        return dayToCivil(Jalali.g2d(date.getFullYear(), date.getMonth() + 1, date.getDate()) + (adjustment || 0))
    }
    return { y: date.getFullYear(), m: date.getMonth() + 1, d: date.getDate() }
}

function toDate(y, m, d, type, adjustment) {
    var date
    if (type === 0) date = Jalali.jalaliToDate(y, m, d)
    else if (type === 2) {
        var g = Jalali.d2g(civilToDay(y, m, d) - (adjustment || 0))
        date = new Date(g.gy, g.gm - 1, g.gd, 12)
    } else date = new Date(y, m - 1, d, 12)
    date.setHours(12, 0, 0, 0) // Noon avoids midnight daylight-saving transitions.
    return date
}

function monthLength(y, m, type) {
    if (type === 0) return Jalali.jalaliMonthLength(y, m)
    if (type === 2) return civilToDay(m === 12 ? y + 1 : y, m === 12 ? 1 : m + 1, 1) - civilToDay(y, m, 1)
    return new Date(y, m, 0).getDate()
}

function monthName(m, type) {
    return (type === 0 ? Jalali.months : type === 2 ? hijriMonths : gregorianMonths)[m - 1] || ""
}

function number(n, type) { return type === 1 ? String(n) : Jalali.fa(n) }

function dateText(date, type, adjustment, shortForm) {
    var p = parts(date, type, adjustment)
    var text = number(p.d, type) + " " + monthName(p.m, type)
    if (shortForm) return text
    text += " " + number(p.y, type)
    return type === 1 ? gregorianWeekdays[date.getDay()] + ", " + text
                      : Jalali.weekdays[date.getDay()] + "، " + text + (type === 2 ? " هـ.ق" : "")
}

function monthCells(type, y, m, adjustment) {
    var first = toDate(y, m, 1, type, adjustment)
    var offset = (first.getDay() + (type === 1 ? 6 : 1)) % 7
    var len = monthLength(y, m, type), cells = []
    for (var i = 0; i < 42; i++) cells.push(i >= offset && i < offset + len ? i - offset + 1 : 0)
    return cells
}
