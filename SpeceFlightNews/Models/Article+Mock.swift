import Foundation

extension Article {

    static let mock = Article(
        id: 1,
        title: "NASA Artemis II Crew Prepares for Lunar Flyby Mission",
        url: "https://www.nasa.gov/artemis-ii",
        imageUrl: "https://images-assets.nasa.gov/image/artemis2/artemis2~orig.jpg",
        newsSite: "NASA",
        summary: "The four-person crew of Artemis II is making final preparations for humanity's first crewed lunar flyby since Apollo 17 in 1972. The mission will take astronauts around the Moon and back, paving the way for a lunar landing on Artemis III.",
        publishedAt: Date(timeIntervalSinceNow: -3600),
        updatedAt: Date(timeIntervalSinceNow: -1800),
        featured: true
    )

    static let mock2 = Article(
        id: 2,
        title: "SpaceX Starship Completes Successful Orbital Test Flight",
        url: "https://www.spacex.com/starship",
        imageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/SpaceX-IFA-LiftOff.jpg/800px-SpaceX-IFA-LiftOff.jpg",
        newsSite: "SpaceX",
        summary: "SpaceX's Starship vehicle successfully completed an orbital test flight, splashing down in the Indian Ocean as planned. The milestone brings the company's vision of fully reusable interplanetary transport closer to reality.",
        publishedAt: Date(timeIntervalSinceNow: -86400),
        updatedAt: Date(timeIntervalSinceNow: -82800),
        featured: false
    )
}
