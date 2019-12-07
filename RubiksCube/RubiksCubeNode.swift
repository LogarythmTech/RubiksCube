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
		}
		
		m.locksAmbientWithDiffuse = true
		return m
	}
}

struct Material {
	var mats: [Color]
	
	func getMat() -> [SCNMaterial] {
		return [mats[0].mat, mats[1].mat, mats[2].mat, mats[3].mat, mats[4].mat, mats[5].mat]
	}
	
	mutating func rotateX(pos: Bool) {
		var temp: [Color] = [Color]()
		
		for m in mats {
			temp.append(m)
		}
		
		
		if(pos) {
			self.mats[0] = temp[4]
			self.mats[2] = temp[5]
			self.mats[4] = temp[2]
			self.mats[5] = temp[0]
		} else {
			self.mats[0] = temp[5]
			self.mats[2] = temp[4]
			self.mats[4] = temp[0]
			self.mats[5] = temp[2]
		}
	}
	
	mutating func rotateY(pos: Bool) {
		let temp: [Color] = self.mats
		
		if(pos) {
			self.mats[0] = temp[3]
			self.mats[1] = temp[0]
			self.mats[2] = temp[1]
			self.mats[3] = temp[2]
		} else {
			self.mats[0] = temp[1]
			self.mats[1] = temp[2]
			self.mats[2] = temp[3]
			self.mats[3] = temp[0]
		}
	}
	
	mutating func rotateZ(pos: Bool) {
		let temp: [Color] = self.mats
		
		if(pos) {
			self.mats[1] = temp[5]
			self.mats[3] = temp[4]
			self.mats[4] = temp[1]
			self.mats[5] = temp[3]
		} else {
			self.mats[1] = temp[4]
			self.mats[3] = temp[5]
			self.mats[4] = temp[3]
			self.mats[5] = temp[1]
		}
	}
	
	
}

class RubiksCubeNode: SCNNode {
	let size: Int
	
	var boxs: [SCNNode]
	var boxMats: [Material]
	let sideColors: [Color]
	let insideColor: Color
	
	let deg90: CGFloat = 3.1415926536/2
	
	let rotationDuration: Double = 1
	let waitDuration: Double = 0.1
	
	init(size: Int) {
		self.size = size
		self.insideColor = Color.black
		self.sideColors = [Color.red, Color.green, Color.blue, Color.yellow, Color.orange, Color.white]
		self.boxs = [SCNNode](repeating: SCNNode(), count: size * size * size)
		self.boxMats = [Material](repeating: Material(mats: [Color.red, Color.green, Color.blue, Color.yellow, Color.orange, Color.white]), count: size * size * size)
		
		super.init()
		
		setup()
		resetBrick()
		rotateBrick()
	}
	
	func setup() {
		for i in 0..<boxs.count {
			self.boxMats[i] = Material(mats: self.sideColors)
		}
	}
	
	func resetBrick() {
		for node in self.childNodes {
			node.removeFromParentNode()
		}
		
		for i in 0..<boxs.count {
			self.boxs[i] = SCNNode()
			let child: SCNNode = SCNNode()
			
			let box = SCNBox(width: 0.98, height: 0.98, length: 0.98, chamferRadius: 0.1)
			var mat: [SCNMaterial] = self.boxMats[i].getMat()
			
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
			
			child.geometry = box
			self.boxs[i].addChildNode(child)
			//self.boxs[i] = child
			child.worldPosition.x = Float(row) - Float(size)/2.0 + 0.5
			child.worldPosition.y = Float(col) - Float(size)/2.0 + 0.5
			child.worldPosition.z = Float(height) - Float(size)/2.0 + 0.5
			
			self.addChildNode(self.boxs[i])
		}
	}
	
	func rotateBrick() {
		rotateZ(pos: false, line: 0)
		
		runAction(SCNAction.wait(duration: rotationDuration + waitDuration), completionHandler: {
			self.rotateBrick()
		})
	}
	
	func rotateX(pos: Bool, line: Int) {
		for i in 0..<boxs.count {
			let row = i % size
			
			if(row == (line % size)) {
				let action = SCNAction.rotateBy(x: deg90 * (pos ? 1 : -1), y: 0, z: 0, duration: TimeInterval(rotationDuration))
				self.boxs[i].runAction(action, completionHandler: {
					self.boxMats[i].rotateX(pos: pos)
					self.resetBrick()
				})
			}
		}
	}
	
	func rotateY(pos: Bool, line: Int) {
		for i in 0..<boxs.count {
			let col = (i / size) % size
			
			if(col == (line % size)) {
				let action = SCNAction.rotateBy(x: 0, y: deg90 * (pos ? 1 : -1), z: 0, duration: TimeInterval(rotationDuration))
				self.boxs[i].runAction(action, completionHandler: {
					self.boxMats[i].rotateY(pos: pos)
					self.resetBrick()
				})
			}
		}
	}
	
	func rotateZ(pos: Bool, line: Int) {
		for i in 0..<boxs.count {
			let height = i / (size * size)
			
			if(height == (line % size)) {
				let action = SCNAction.rotateBy(x: 0, y: 0, z: deg90 * (pos ? 1 : -1), duration: TimeInterval(rotationDuration))
				self.boxs[i].runAction(action, completionHandler: {
					self.boxMats[i].rotateZ(pos: pos)
					self.resetBrick()
				})
			}
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
}
