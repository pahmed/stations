#  Bus stations routes and tracking demo

A demo application that plots stations and draws the route that the bus will move through along the ride on the map.

## Application Features

- A user should see a list of available lines
- On seleting a line, the list of stations will be rendered on the map
- A user should see a callout with the station details on tapping a specific station
- Simulate a bus moving on the drawn route
- Tapping a station callout will present the station details with transition animation
- A user should be able to bookmark a station

## Overall Architecture

The application follows VIP (View - Interactor - Presenter) when possible, but also MVC when it is better to use it

The VIP pattern, this is a unidirectional data flow pattern. The implementation of this pattern is inspired by [Clean Swift](http://clean-swift.com/) based on Uncle bob [Clean Architecture](https://8thlight.com/blog/uncle-bob/2012/08/13/the-clean-architecture.html)

![VIP](http://clean-swift.com/wp-content/uploads/2015/08/VIP-Cycle.png)

### View

A `View` is represented by a UIViewController, this is responsible for receiving user events and pass it to the interactor in a form of request to do some business logic. A `View` is also responsible for displaying the presentable view model it gets from the presenter.
A `View` can send messages (commads) **only** to the `Interactor`, and can receive mesasges **only** from the `Presenter`

### Interactor

An `Interactor` is an object, that is responsible for handling the business logic, it gets the data from a store, doing any business validation and passes the results to the `Presenter`
A `View` can send messages (data objects) **only** to the `Presenter`, and can receive mesasges **only** from the `View`

### Presenter

A `Presenter` is responsible for mapping the raw data it gets from the `Interactor` to a form of view model that can easily be displayed by the `View` without extra processing
A `Presenter` can send messages (view models) **only** to the `View`, and can receive mesasges **only** from the `Interactor`

## Project Structure

##### Models
This is a directory that contains the app model objects, usually those are just plain object for storing values

##### Utils
This direcory contains utility/helper classes

##### Constants
Application constants should be put there, it is prefered also to be grouped by its business domain e.g. Color, Icon, etc.

##### Networking
This contains the networking module, this module represents the networking access layer that is used to make any network call
The `API` file has the applications APIs  that can be called, new APIs should be added there as well

##### Scenes
This directory contains the application scenes, a scene usually represents a screen. A scene is usually is implemented using the `VIP` archetecture. 
So, it usually consists of 3 main files `View`, `Interactor`, `Presenter`, a  `Models` file is created as well when needed.

In case of using MVC, a scene group should have the `ViewController` plus the other related components it uses

Any new scene should be in a separate directory/group

## Libraries
### [GoogleMaps](https://developers.google.com/maps/documentation/ios/)
### [Alamofire](https://github.com/Alamofire/Alamofire)
### [RxSwift](https://github.com/ReactiveX/RxSwift)
### [Hero](https://github.com/HeroTransitions/Hero)
### [Kingfisher](https://github.com/onevcat/Kingfisher)
