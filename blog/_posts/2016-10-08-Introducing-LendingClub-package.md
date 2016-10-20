---
title: "Introducing the LendingClub Package"
author: "Ryan Kuhn"
output:  html_document
layout: post
date: "October 8, 2016"
htmlwidgets: false
comments: true
tags: [R, P2PLending]
---



### Introduction  
Lending Club is a peer-to-peer lending site where personal loans are distributed in $25 shares for investors to purchase. This LendingClub package makes it easy for you to see your investor account data such as the amount of free cash or the details on which loans you own. This package is a convenience wrapper for the Lending Club API so that you get get the data into R. You can learn more about the API by reading [Lending Club's API documentation](https://www.lendingclub.com/developers/lc-api.action)

<style>
    #wrap { width: 600px; height: 390px; padding: 0; overflow: hidden; }
    #frame { width: 800px; height: 600px; border: 1px solid black; }
	/*
    #frame {
        -webkit-transform: scale(0.80);
		-moz-transform: scale(0.80);
		-o-transform: scale(0.80);
		-ms-transform: scale(0.80);        
        -moz-transform-origin: 0 0;
        -o-transform-origin: 0 0;
        -webkit-transform-origin: 0 0;
    }
	*/
</style>

<iframe src= "/images/LendingClubPres.html" scrolling="no" id="frame"></iframe>