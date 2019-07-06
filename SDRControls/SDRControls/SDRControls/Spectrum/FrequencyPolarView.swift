//
//  FrequencyPolarView.swift
//  ViScope
//
//  Created by Davorin Madaric on 23/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Foundation

public final class FrequencyPolarView: UIView {
    
    
    // MARK: - Init
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        setup()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        setup()
    }
    
    private func setup() {
        wantsLayer = true
    
    
    
    
    }
    
    
    public override func draw(_ dirtyRect: NSRect) {
        
        
        
    }
    
}
