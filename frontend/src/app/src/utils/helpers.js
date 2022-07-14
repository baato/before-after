export function generateYears() {
    const currentYear = new Date().getFullYear();
    const yearsSupportedTill = 2015;
    let years = [];
    for (let i = currentYear; i >= yearsSupportedTill; i--) {
        years.push(i);
    }
    return years;
}