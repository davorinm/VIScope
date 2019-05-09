//: Workout - noun: a place where people can play

//: Make c(n,k) where c is combination of k items selected from n items.

//: Result

func addCombo(prevCombo: [Int], var pivotList: [Int]) -> [([Int], [Int])] {
    
    return (0..<pivotList.count)
        .map {
            _ -> ([Int], [Int]) in
            (prevCombo + [pivotList.removeAtIndex(0)], pivotList)
    }
}
func c(n: Int, m: Int) -> [[Int]] {
    
    return [Int](1...m)
        .reduce([([Int](), [Int](0..<n))]) {
            (accum, _) in
            accum.flatMap(addCombo)
        }.map {
            $0.0
    }
}


c(4, m: 2)
