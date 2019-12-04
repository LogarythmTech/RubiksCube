//
//  BrickNode.swift
//  RubiksCube
//
//  Created by Logan Richards on 12/3/19.
//  Copyright © 2019 ZER0 Tech. All rights reserved.
//

import Foundation
import SceneKit


enum Color {
	case red, green, blue, white, black, yellow, orange, purple
	
	var mat : SCNMaterial {
		let m = SCNMaterial()
		
		switch self {
		case .red:
			m.diffuse.contents = UIColor.red
		case .green:
			m.diffuse.contents = UIColor.green
		case .blue:
			m.diffuse.contents = UIColor.blue
		case .white:
			m.diffuse.contents = UIColor.white
		case .black:
			m.diffuse.contents = UIColor.black
		case .yellow:
			m.diffuse.contents = UIColor.yellow
		case .orange:
			m.diffuse.contents = UIColor.orange
		case .purple:
			m.diffuse.contents = UIColor.purple
		default:
			break
		}
		
		m.locksAmbientWithDiffuse = true
		return m
    }
}

class RubiksCubeNode: SCNNode {
	let size: Int
	
	var boxs: [SCNNode]
	let sideColors: [Color]
	let insideColor: Color
	
	init(size: Int) {
		self.size = size
		self.insideColor = Color.black
		self.sideColors = [Color.red, Color.green, Color.blue, Color.yellow, Color.orange, Color.white]
		self.boxs = [SCNNode](repeating: SCNNode(), count: size * size * size)
		
		print(self.boxs.count)
		
		super.init()
		
		for i in 0..<boxs.count {
			self.boxs[i] = SCNNode()
			
			let box = SCNBox(width: 0.98, height: 0.98, length: 0.98, chamferRadius: 0.1)
			var mat: [SCNMaterial] = [sideColors[0].mat, sideColors[1].mat, sideColors[2].mat, sideColors[3].mat, sideColors[4].mat, sideColors[5].mat]
			
			let row = i % size
			let col = (i / size) % size
			let height = i / (size * size)
			
			
			//Change insides to black
			if(height != size - 1) {
				mat[0] = insideColor.mat
			}
			
			if(row != size - 1) {
				mat[1] = insideColor.mat
			}
			
			if(height != 0) {
				mat[2] = insideColor.mat
			}
			
			if(row != 0) {
				mat[3] = insideColor.mat
			}
			
			if(col != size - 1) {
				mat[4] = insideColor.mat
			}
			
			if(col != 0) {
				mat[5] = insideColor.mat
			}
			
			box.materials = mat
			
			self.boxs[i].geometry = box
			
			self.boxs[i].worldPosition.x = Float(row)
			self.boxs[i].worldPosition.y = Float(col)
			self.boxs[i].worldPosition.z = Float(height)
			
			self.addChildNode(self.boxs[i])
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	

}
