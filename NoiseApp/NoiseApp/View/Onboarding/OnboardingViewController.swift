//
//  OnboardingViewController.swift
//  NoiseApp
//
//  Created by Mitchel Santillan Cruz on 10/25/22.
//

import UIKit

class OnboardingViewController: UIViewController
{
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var pageCtrl: UIPageControl!
    
    var currentPage = 0
    {
        didSet
        {
            pageCtrl.currentPage = currentPage
            if (currentPage == slides.count - 1)
            {
                nextBtn.setTitle("Get Started", for: .normal)
            }
            else
            {
                nextBtn.setTitle("Next", for: .normal)
            }
        }
    }
    
    let slides: [OnboardingSlide] =
    [
        OnboardingSlide(title: "LEQ", description: "Equivalent Continuous Sound Pressure Level, or Leq/LAeq, is the constant noise level that would result in the same total sound energy being produced over a given period.", image: #imageLiteral(resourceName: "LEQ")),
        OnboardingSlide(title: "PEAK", description: "Peak is the maximum value reached by the sound pressure.", image: #imageLiteral(resourceName: "PEAK")),
        OnboardingSlide(title: "Instantaneous dB", description: "The current decibels being picked up.", image: #imageLiteral(resourceName: "dB"))
    ]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @IBAction func nextBtnClicked(_ sender: UIButton)
    {
        if (currentPage == slides.count - 1)
        {
            let controller = storyboard?.instantiateViewController(identifier: "MainView") as! RecordViewController
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .flipHorizontal
            UserDefaults.standard.hasOnboarded = true 
            present(controller, animated: true)
        }
        else
        {
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.identifier, for: indexPath) as! OnboardingCollectionViewCell
        cell.setup(slides[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
    }
}
