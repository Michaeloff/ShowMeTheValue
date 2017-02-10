# Show Me the Value - Available on the Apple App Store

"Show Me the Value!" is a GPS home estimation tool using Zillow/Google REST APIs written in Swift.

The app displays a map with your current location marked by a blue circle. The size of the circle indicates the accuracy range, with a smaller circle suggesting a higher confidence in your position. Waiting several seconds generally improves accuracy.

Select "Find Homes Near Me" to use your current location to search for a list of potential addresses. Choose an address or enter one manually to get an estimate and other data about the property. If the address you are interested in isn't listed, try changing the search radius and then selecting "Search Again".

How it works: The map and current location coordinates are provided by Apple services. Google provides the ability to look up addresses based on latitude and longitude. The center and four points around the search radius are used to find addresses. The address selected is then used to query Zillow for home data. If there are no Zillow photos of the house, a Google street view is shown if available.
