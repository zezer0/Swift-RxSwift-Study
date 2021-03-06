//
//  ViewController.swift
//  GoodWeatherApp
//
//  Created by ėŽėė  on 2021/12/15.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cityNameTextField.rx.controlEvent(.editingDidEndOnExit)
            .asObservable()
            .map { self.cityNameTextField.text }
            .subscribe(onNext: {
                city in
                if let city = city {
                    if city.isEmpty {
                        self.displayWeather(nil)
                    } else {
                        self.fetchWeather(by: city)
                    }
                }
            }, onError: {
                _ in
                print("error ðĪĢ")
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
 
    }
    
    private func displayWeather(_ weather: Weather?) {
        if let weather = weather {
            self.temperatureLabel.text = "\(weather.temp)â"
            self.humidityLabel.text = "\(weather.humidity)ðĶ"
        } else {
            self.temperatureLabel.text = "ð"
            self.humidityLabel.text = "â"
        }
    }
    
    private func fetchWeather(by city: String) {
        guard let city = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed), let url = URL.urlForWeatherAPI(city: city) else { return }
        
        let resource = Resource<WeatherResult>(url: url)
        
        let search = URLRequest.load(resource: resource)
            .retry(3)
            .catch({ error in
                print("Error ð!!!", error.localizedDescription)
                return Observable.just(WeatherResult.empty)
            })
            .asDriver(onErrorJustReturn: WeatherResult.empty)

        search.map { "\($0.main.temp)â"}
        .drive(self.temperatureLabel.rx.text)
        .disposed(by: disposeBag)
        
        search.map { "\($0.main.humidity)ðĶ" }
        .drive(self.humidityLabel.rx.text)
        .disposed(by: disposeBag
        )
    }
}

