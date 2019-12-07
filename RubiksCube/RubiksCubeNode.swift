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
	var newMat: [Color] //This stores what the mat will be for that block after the rotation is complets
	
	init(mats: [Color]) {
		self.mats = mats
		self.newMat = mats
	}
	
	func getMat() -> [SCNMaterial] {
		return [mats[0].mat, mats[1].mat, mats[2].mat, mats[3].mat, mats[4].mat, mats[5].mat]
	}
	
	mutating func setMat() {
		self.mats = newMat
	}
	
	mutating func rotateX(pos: Bool, temp: [Color]) {
		if(pos) {
			self.newMat[0] = temp[4]
			self.newMat[1] = temp[1]
			self.newMat[2] = temp[5]
			self.newMat[3] = temp[3]
			self.newMat[4] = temp[2]
			self.newMat[5] = temp[0]
		} else {
			self.newMat[0] = temp[5]
			self.newMat[1] = temp[1]
			self.newMat[2] = temp[4]
			self.newMat[3] = temp[3]
			self.newMat[4] = temp[0]
			self.newMat[5] = temp[2]
		}
	}
	
	mutating func rotateY(pos: Bool, temp: [Color]) {
		if(pos) {
			self.newMat[0] = temp[3]
			self.newMat[1] = temp[0]
			self.newMat[2] = temp[1]
			self.newMat[3] = temp[2]
			self.newMat[4] = temp[4]
			self.newMat[5] = temp[5]
		} else {
			self.newMat[0] = temp[1]
			self.newMat[1] = temp[2]
			self.newMat[2] = temp[3]
			self.newMat[3] = temp[0]
			self.newMat[4] = temp[4]
			self.newMat[5] = temp[5]
		}
	}
	
	mutating func rotateZ(pos: Bool, temp: [Color]) {
		if(pos) {
			self.newMat[0] = temp[0]
			self.newMat[1] = temp[5]
			self.newMat[2] = temp[2]
			self.newMat[3] = temp[4]
			self.newMat[4] = temp[1]
			self.newMat[5] = temp[3]
		} else {
			self.newMat[0] = temp[0]
			self.newMat[1] = temp[4]
			self.newMat[2] = temp[2]
			self.newMat[3] = temp[5]
			self.newMat[4] = temp[3]
			self.newMat[5] = temp[1]
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
	
	//MARK: - Initalizers
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
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
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
			self.boxMats[i].setMat()
			self.boxs[i] = SCNNode()
			let child: SCNNode = SCNNode()
			
			let box = SCNBox(width: 0.98, height: 0.98, length: 0.98, chamferRadius: 0.1)
			var mat: [SCNMaterial] = self.boxMats[i].getMat()
			
			let row = getX(i)
			let col = getY(i)
			let height = getZ(i)
			
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
		let dir: Int = Int.random(in: 0..<3)
		let line: Int = Int.random(in: 0..<self.size)
		
		switch dir {
		case 0:
			rotateX(pos: Bool.random(), line: line)
		case 1:
			rotateY(pos: Bool.random(), line: line)
		case 2:
			rotateZ(pos: Bool.random(), line: line)
		default:
			rotateZ(pos: false, line: 0)
		}
		
		runAction(SCNAction.wait(duration: rotationDuration + waitDuration), completionHandler: {
			self.rotateBrick()
		})
	}
	
	func rotateX(pos: Bool, line: Int) {
		for i in 0..<boxs.count {
			if(getX(i) == line) {
				let action = SCNAction.rotateBy(x: deg90 * (pos ? 1 : -1), y: 0, z: 0, duration: TimeInterval(rotationDuration))
				self.boxMats[i].rotateX(pos: pos, temp: self.boxMats[rotateXto(pos: pos, index: i)].mats)
				self.boxs[i].runAction(action, completionHandler: {
					self.resetBrick()
				})
			}
		}
	}
	
	//This takes in an int [index] and return what index will replace it with
	private func rotateXto(pos: Bool, index: Int) -> Int {
		let x = getX(index) //Stays the same always
		let y = pos ? (self.size - getY(index) - 1) : getY(index)
		let z = pos ? getZ(index) : (self.size - getZ(index) - 1)
		
		return getIndex(x, z, y)
 	}
	
	func rotateY(pos: Bool, line: Int) {
		for i in 0..<boxs.count {
			if(getY(i) == line) {
				let action = SCNAction.rotateBy(x: 0, y: deg90 * (pos ? 1 : -1), z: 0, duration: TimeInterval(rotationDuration))
				self.boxMats[i].rotateY(pos: pos, temp: self.boxMats[rotateYto(pos: pos, index: i)].mats)
				self.boxs[i].runAction(action, completionHandler: {
					self.resetBrick()
				})
			}
		}
	}
	
	//This takes in an int [index] and return what index will replace it with
	private func rotateYto(pos: Bool, index: Int) -> Int {
		let x = pos ? getX(index) : (self.size - getX(index) - 1)
		let y = getY(index) //Stays the same always
		let z = pos ? (self.size - getZ(index) - 1) : getZ(index)
		
		return getIndex(z, y, x)
	}
	
	func rotateZ(pos: Bool, line: Int) {
		for i in 0..<boxs.count {
			if(getZ(i) == line) {
				let action = SCNAction.rotateBy(x: 0, y: 0, z: deg90 * (pos ? 1 : -1), duration: TimeInterval(rotationDuration))
				self.boxMats[i].rotateZ(pos: pos, temp: self.boxMats[rotateZto(pos: pos, index: i)].mats)
				self.boxs[i].runAction(action, completionHandler: {
					self.resetBrick()
				})
			}
		}
	}
	
	//This takes in an int [index] and return what index will replace it with
	private func rotateZto(pos: Bool, index: Int) -> Int {
		let x = pos ? (self.size - getX(index) - 1) : getX(index)
		let y = pos ? getY(index) : (self.size - getY(index) - 1)
		let z = getZ(index) //Stays the same always
		
		return getIndex(y, x, z)
	}
	
	//Getters
	func getX(_ index: Int) -> Int {
		return index % self.size
	}
	
	func getY(_ index: Int) -> Int {
		return (index / self.size) % self.size
	}
	
	func getZ(_ index: Int) -> Int {
		return index / (self.size * self.size)
	}
	
	func getIndex(_ x: Int, _ y: Int, _ z: Int) -> Int {
		return (z * size * size) + (y * size) + x
	}
	
	
}
