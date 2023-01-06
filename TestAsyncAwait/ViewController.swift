//
//  ViewController.swift
//  TestAsyncAwait
//
//  Created by Pavel Tarasevich on 5/1/23.
//

import UIKit

enum TestError: Error {
  case imageLoading
}

class ViewController: UIViewController {
  @IBOutlet var imageView: UIImageView!

  enum WhatToTest {
    case unstructuredTask
    case detachedTask
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    let whatToTest = WhatToTest.unstructuredTask

    switch whatToTest {
    case .unstructuredTask:
      Task {
        print("enter unstructuredTask")
        let image = try await loadedImage()
        imageView.image = image
        print("exit unstructuredTask")
      }
    case .detachedTask:
      Task.detached(priority: .background) {
        print("enter detachedTask")
        let image = try await self.loadedImage()
        print("exit detachedTask = \(image.size)")
      }
    }
  }

  func loadedImage() async throws -> UIImage {
    let loadCounts = 100
    for i in 0..<100 {
      let url = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Fronalpstock_big.jpg/1200px-Fronalpstock_big.jpg")!
      let request = URLRequest(url: url)
      let session = URLSession(configuration: .ephemeral)
//      // 1
//      async let urlSessionAsyncResult = session.data(for: request)
//      let urlSessionResult = try await urlSessionAsyncResult // returns (Data, URLResponse)
      // 2
      let (data, response) = try await session.data(for: request) // returns (Data, URLResponse)
      guard let image = UIImage(data: data) else {
        throw TestError.imageLoading
      }
      if i == loadCounts - 1 {
        return image
      }
    }

    throw TestError.imageLoading
  }
}

// MARK: - Collection View

extension ViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 50
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestCell", for: indexPath)
    cell.contentView.backgroundColor = UIColor.random
    return cell
  }
}

// MARK: - UIColor+Random

extension UIColor {
  static var random: UIColor {
    return UIColor(
      red: .random(in: 0...1),
      green: .random(in: 0...1),
      blue: .random(in: 0...1),
      alpha: 1.0
    )
  }
}
