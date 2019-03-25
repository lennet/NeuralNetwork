//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import UIKit

extension Array {
    func randomElements(n: Int) -> [Element] {
        return Array(shuffled().prefix(n))
    }
}

public class ArtificalDataSets {
    public class func circular(numberOfPointsPerClass: Int = 250) -> DataSetProtocol {
        func generateValues(numberOfPoints: Int, minRadius: Double = 0, maxRadius: Double, classValue: Double) -> [[Double]] {
            let rows: [[Double]] = (0 ..< numberOfPoints).map { _ in
                let a = Double.random(in: 0 ..< 1) * 2 * Double.pi
                let r = maxRadius * sqrt(Double.random(in: 0 ..< 1)) + minRadius

                let x = r * cos(a)
                let y = r * sin(a)

                return [x, y, classValue]
            }
            return rows
        }
        let radius: Double = 10
        let minRadius: Double = 5

        let values = generateValues(numberOfPoints: numberOfPointsPerClass, maxRadius: 5, classValue: 0) + generateValues(numberOfPoints: numberOfPointsPerClass, minRadius: minRadius + 1, maxRadius: radius, classValue: 1).shuffled()

        let input = values.map { row in Array(row[0 ..< 2]) }
        let output: [[Double]] = values.map { row in
            if row[2] == 1 {
                return [1, 0]
            } else {
                return [0, 1]
            }
        }

        return DataSet(input: Mat(values: input), output: Mat(values: output), inputLabels: ["X", "Y"])
    }

    private class func randomPointsForShape(path: UIBezierPath, classValue: Double) -> [[Double]] {
        let allPoints = path.allPoints
        return allPoints.randomElements(n: allPoints.count / 5).map { point in
            [Double(point.x), Double(point.y), classValue]
        }
    }

    public class func fourCorners() -> DataSetProtocol {
        let center = CGPoint(x: 50, y: 50)
        let distanceFromCenter: CGFloat = 10
        let size = CGSize(width: 10, height: 50)

        let bottomRightShape = UIBezierPath(rect: CGRect(x: center.x + distanceFromCenter, y: center.y + distanceFromCenter, width: size.width, height: size.height))
        bottomRightShape.append(UIBezierPath(rect: CGRect(x: center.x + distanceFromCenter, y: center.y + distanceFromCenter, width: size.height, height: size.width)))
        let bottomRight = randomPointsForShape(path: bottomRightShape, classValue: 3)

        let topRightShape = UIBezierPath(rect: CGRect(x: center.x + distanceFromCenter, y: center.y - distanceFromCenter, width: size.width, height: -size.height))
        topRightShape.append(UIBezierPath(rect: CGRect(x: center.x + distanceFromCenter, y: center.y - distanceFromCenter, width: size.height, height: size.width)))
        let topRight = randomPointsForShape(path: topRightShape, classValue: 2)

        let bottomLeftShape = UIBezierPath(rect: CGRect(x: center.x - distanceFromCenter, y: center.y + distanceFromCenter, width: size.width, height: size.height))
        bottomLeftShape.append(UIBezierPath(rect: CGRect(x: center.x - distanceFromCenter, y: center.y + distanceFromCenter, width: -size.height, height: size.width)))
        let bottomLeft = randomPointsForShape(path: bottomLeftShape, classValue: 0)

        let topLeftShape = UIBezierPath(rect: CGRect(x: center.x - distanceFromCenter, y: center.y - distanceFromCenter, width: size.width, height: -size.height))
        topLeftShape.append(UIBezierPath(rect: CGRect(x: center.x - distanceFromCenter, y: center.x - distanceFromCenter, width: -size.height, height: size.width)))
        let topLeft = randomPointsForShape(path: topLeftShape, classValue: 1)

        let allValues = (topRight + bottomRight + bottomLeft + topLeft).shuffled()

        let input = allValues.map { row in Array(row[0 ..< 2]) }
        let output: [[Double]] = allValues.map { row in
            switch Int(row[2]) {
            case 0:
                return [1, 0, 0, 0]
            case 1:
                return [0, 1, 0, 0]
            case 2:
                return [0, 0, 1, 0]
            case 3:
                return [0, 0, 0, 1]
            default:
                fatalError()
            }
        }
        return DataSet(input: Mat(values: input), output: Mat(values: output), inputLabels: ["X", "Y"])
    }
}
