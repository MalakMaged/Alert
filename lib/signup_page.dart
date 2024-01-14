import 'package:flutter/material.dart';
import 'signup_form.dart';



class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text('ALERT'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
                                       
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                
                'Create an account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  
                ),
                
              ),
              
              SizedBox(height: 20),
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.red, // Set the red stroke color
                    width: 3.0,
                  ),
                  
                ),
                
                child: ElevatedButton(
                  onPressed: () 
                  {
                    // Add logic to handle photo upload
                  },
                  child: Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: Colors.grey[700],
                  ),
                  
                  style: ElevatedButton.styleFrom(
                    primary: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  
                ),
                
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () 
                {
                  
                  // Add logic to handle gallery photo upload
                  
                },
                
                child: Text('Upload Photo from Gallery'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              
              SignUpForm(),
              
            ],
            
          ),
          
        ),
        
      ),
      
    );
    
  }
  
}
