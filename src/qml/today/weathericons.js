// https://openweathermap.org/weather-conditions
var iconNameByOwmCode = {
    '200': 'ios-thunderstorm-outline',
    '201': 'ios-thunderstorm-outline',
    '202': 'ios-thunderstorm-outline',
    '210': 'ios-thunderstorm-outline',
    '211': 'ios-thunderstorm-outline',
    '212': 'ios-thunderstorm-outline',
    '221': 'ios-thunderstorm-outline',
    '230': 'ios-thunderstorm-outline',
    '231': 'ios-thunderstorm-outline',
    '232': 'ios-thunderstorm-outline',
    
    '300': 'ios-rainy-outline',
    '301': 'ios-rainy-outline',
    '302': 'ios-rainy-outline',
    '310': 'ios-rainy-outline',
    '311': 'ios-rainy-outline',
    '312': 'ios-rainy-outline',
    '313': 'ios-rainy-outline',
    '314': 'ios-rainy-outline',
    '321': 'ios-rainy-outline',
    
    '500': 'ios-rainy-outline',
    '501': 'ios-rainy-outline',
    '502': 'ios-rainy-outline',
    '503': 'ios-rainy-outline',
    '504': 'ios-rainy-outline',
    '511': 'ios-snow-outline',
    '520': 'ios-rainy-outline',
    '521': 'ios-rainy-outline',
    '522': 'ios-rainy-outline',
    '531': 'ios-rainy-outline',
    
    '600': 'ios-snow-outline',
    '601': 'ios-snow-outline',
    '602': 'ios-snow-outline',
    '611': 'ios-snow-outline',
    '612': 'ios-snow-outline',
    '615': 'ios-snow-outline',
    '616': 'ios-snow-outline',
    '620': 'ios-snow-outline',
    '621': 'ios-snow-outline',
    '622': 'ios-snow-outline',
    
    '701': 'ios-cloudy-outline',
    '711': 'ios-cloudy-outline',
    '721': 'ios-cloudy-outline',
    '731': 'ios-cloudy-outline',
    '741': 'ios-cloudy-outline',
    '751': 'ios-cloudy-outline',
    '761': 'ios-cloudy-outline',
    
    '800': 'ios-sunny-outline',
    '801': 'ios-partly-sunny-outline',
    '802': 'ios-cloudy-outline',
    '803': 'ios-cloudy-outline',
    '804': 'ios-cloudy-outline',
    
    '903': 'ios-snow-outline',
    '904': 'ios-flame-outline',
    '905': 'ios-sunny-outline',
    '906': 'ios-snow-outline',
    
    '950': 'ios-sunny-outline',
    '951': 'ios-sunny-outline',
    '952': 'ios-sunny-outline',
    '953': 'ios-sunny-outline',
    '954': 'ios-sunny-outline',
    '955': 'ios-sunny-outline',
    '956': 'ios-sunny-outline',
};

function getIconName(iconName) {
    var iconCodeParts = iconNameByOwmCode[iconName]
    if (!iconCodeParts)
        return 'ios-alert-outline';
    return iconCodeParts
}

