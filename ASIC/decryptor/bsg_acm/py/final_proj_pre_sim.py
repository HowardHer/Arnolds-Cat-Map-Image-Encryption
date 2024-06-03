

import os
import os.path as osp
import yaml # Not installed by default
import shutil
import numpy as np # Not installed by default
import acm
from argparse import ArgumentParser
from tqdm import tqdm # Not installed by default
from math import ceil, log2
from PIL import Image

# Default values:
trace_data_width = 64 # Data traces should be this many bits wide
output_dir = 'out' # GIFs are written here
default_trace_fout = 'v/bsg_trace_master_0.tr' # Default output file
img_name = 'bigbf.png'

# TODO: Make the paths more generalized
set_user_path = '/homes/' + os.getlogin()
work_dir_path = osp.join(set_user_path, 'ee526/Arnolds-Cat-Map-Image-Encryption')
py_dir_path = osp.join(work_dir_path, 'ASIC/decryptor/bsg_acm/py')


def get_bmp_zero_idxs(img_name, out_dir, side_len=50):
  '''
  Converts given Image into bitmap, risize into 50x50.
  '''
  print(img_name)
  # Load image from full image path
  img_path = osp.join(work_dir_path, ('photos/' + img_name))
  img_name = img_path.split('/')[-1].split('.')[0]
  img = Image.open(img_path).resize((side_len, side_len))
  ary = np.array(img)

  # Split the three channels
  if len(ary.shape) == 3:
    r,g,b = np.split(ary,3,axis=2)
    r=r.reshape(-1)
    g=r.reshape(-1)
    b=r.reshape(-1)

    # Standard RGB to grayscale 
    bitmap = list(map(lambda x: 0.299 * x[0] + 0.587 * x[1] + 0.114 * x[2], zip(r,g,b)))
    bitmap = np.array(bitmap).reshape([ary.shape[0], ary.shape[1]])

  else:
    bitmap = ary
  
  # switch s, y order
  bmp_z_idx = np.argwhere(bitmap < 200)
  bmp_z_idx = np.roll(bmp_z_idx, 1, axis=1)

  # DEBUG: Save as img
  im = Image.fromarray(bitmap.astype(np.uint8))
  im.save(osp.join(out_dir, (img_name + '.bmp')))
  img.save(osp.join(out_dir, (img_name + '_resized.bmp')))
  
  return bmp_z_idx.tolist()



def send_game_req(fout, board:np.ndarray, length, width, max_len):
  '''
  Given an image board and a encryption key, write this to the trace file so the
  data is sent to the DUT.
  '''
  key_len_formatter = f'{{:0{ ceil(log2(max_len+1)) }b}}'
  key_len_bin = key_len_formatter.format(length)
  fout.write(f'### sending board config (encryption key -> {length}) ###\n')
  # Write traces to send data
  board_in = board.copy()
  board_in = board_in.reshape((width**2, 1))
  board_in = board_in.squeeze()
  board_in = np.pad(board_in, (0, trace_data_width), 'constant', constant_values=0) # Pad with 0s
  wr_idx = 0
  while wr_idx < width**2:
    if wr_idx==0:
      data = np.flip(board_in[0:(trace_data_width-len(key_len_bin))])
      wr_idx+=(trace_data_width-len(key_len_bin))
      fout.write(f'0001____0_00000000000_{"".join([str(x) for x in data])}_{key_len_bin}\n')
    else:
      data = np.flip(board_in[wr_idx:wr_idx+trace_data_width])
      wr_idx+=trace_data_width
      fout.write(f'0001____0_00000000000_{"".join([str(x) for x in data])}\n')
  fout.write('\n')
  return board


def send_game_check(fout, board:np.ndarray, width):
  '''
  Given an image board, write the output expected trace to the trace file.
  '''
  fout.write(f'### Checking board output ###\n')
  board = board.reshape((width**2, 1))
  board = board.squeeze()
  board = np.pad(board, (0, trace_data_width), 'constant', constant_values=0) # Pad with 0s
  wr_idx = 0
  while wr_idx < width**2:
    data = np.flip(board[wr_idx:wr_idx+trace_data_width])
    wr_idx+=trace_data_width
    fout.write(f'0010____0_00000000000_{"".join([str(x) for x in data])}\n')
  fout.write('\n')

# Add one image into the list for gif
def add_image_to_list(list, board, disp):
  '''
  Given an image board, append to GIF list
  '''
  # Add a the next image to a list of images
  list.append(acm.board_to_img2(board, disp['pixel_size'],
                                        a=disp['alive_color'],
                                        d=disp['dead_color']))

# Add multiple images into list for gif
def add_images_to_list(list, boards, disp):
  '''
  Given list of image boards, append each board to GIF list
  '''
  for board in boards:
    # Add a the next image to a list of images
    list.append(acm.board_to_img2(board, disp['pixel_size'],
                                          a=disp['alive_color'],
                                          d=disp['dead_color']))


def main():
  parser = ArgumentParser()
  parser.add_argument('-cfg', required=True, 
                      help='The input config file (in yaml format)')
  parser.add_argument('-out', required=False, default=default_trace_fout, 
                      help=f'Output trace file, defaults to "{default_trace_fout}"')
  parser.add_argument('-img', required=False, default=img_name, 
                    help=f'The input image to encrypt')
  args = parser.parse_args()
  
  print(f'Clearing any previous output in "{output_dir}"...')
  # Create output directory for testbench .data files
  try: shutil.rmtree(output_dir)
  except(FileNotFoundError): pass
  os.mkdir(output_dir)
  
  cfg = yaml.safe_load(open(args.cfg, 'r'))
  width = cfg["board"]["width"]
  max_len = cfg["board"]["max_length"]
  acm_iterations = 0
  acm_elapsed_time = 0
  with open(args.out, 'w') as fout:

    # Write trace header
    fout.write('')
    fout.write(f'# This trace file was generated by "final_project_pre_sim.py" with the config file "{args.cfg}", do not directly modify!\n')
    fout.write('\n')
    fout.write(f'# Encrypting Image Size: {width}x{width}, Encryption Key Max Length: {cfg["board"]["max_length"]}\n')
    fout.write(f'# Beginning trace ROM with {len(cfg["acts"])} actions:\n')
    fout.write('\n')

    # Write the config for every game...
    for (idx, acts) in enumerate(cfg['acts']):
      assert acts['encrypt_key'] <= max_len, 'Max key length exceded!'
      fout.write(f'########## Action: {acts["checks"]} ##########\n')
      # Generate the initial board
      board = np.zeros((width, width), dtype=np.uint8)
      
      # Load bitmap image onto board 
      alive_list = get_bmp_zero_idxs(img_name, output_dir, cfg["board"]["width"])
      
      if acts['origin'] == 'center':
        for ii, p in enumerate(alive_list): alive_list[ii] = [p[0]+(width//2), p[1]+(width//2)]
      for pt in alive_list: board[pt[0]][pt[1]] = 1
      board = board.transpose()

      fname = img_name.split('.')[0]
      expected_fout = f'{fname}.gif'

      ############## 
      # ENCRYPTION : Generate the trace for this action: only check the last frame
      ############## 
      if acts["checks"] == "ENCRYPT":
        send_game_req(fout, board, acts['encrypt_key'], width, max_len) # Send initial data
        print(f'Generating expected results for {acts["checks"]} version ...')
        
        # Simulate Arnold's Cat Map
        encrypt_imgs = []   # Storing each frame of Encryption
        with tqdm(range(acts['encrypt_key']), disable=False) as tq:
          # Perform Encryption, saving each frame into gif
          add_image_to_list(encrypt_imgs, board, cfg["display"])  # Add initial frame to gif
          for i in tq:
            board = acm.ArnoldCatTransform(board)
            add_image_to_list(encrypt_imgs, board, cfg["display"])

          # Record stats
          acm_iterations += tq.format_dict['total']
          acm_elapsed_time += tq.format_dict['elapsed']
        
        # Save game as a GIF
        acm.save_gif(encrypt_imgs, os.path.join(output_dir, 'encrypting.gif'), frame_dur=cfg['display']['frame_dur_ms'])
        send_game_check(fout, board, width) # Send output check


      ############## 
      # DECRYPTION : Generate the trace for this action: only check the last frame
      ##############
      if acts["checks"] == "DECRYPT":
        print(f'Generating expected results for {acts["checks"]} version ...')
        
        # Simulate Game of Life
        encrypt_imgs = []   # Storing each frame of Encryption
        decrypt_imgs = []
        with tqdm(range(acts['encrypt_key']), disable=False) as tq:
          # Perform Encryption, saving each frame into gif
          add_image_to_list(encrypt_imgs, board, cfg["display"])  # Add initial frame to gif
          for i in tq:
            board = acm.ArnoldCatTransform(board)
            add_image_to_list(encrypt_imgs, board, cfg["display"])
            
          send_game_req(fout, board, acts['encrypt_key'], width, max_len) # Send initial data
          
          # Perform Decryption, saving each frame into gif
          add_image_to_list(decrypt_imgs, board, cfg["display"])  # Add initial frame to gif
          board, boards = acm.ArnoldCatDecryption(board, acts['encrypt_key'])
          
          for b in boards:
            add_image_to_list(decrypt_imgs, b, cfg["display"])
          add_image_to_list(decrypt_imgs, board, cfg["display"])

          send_game_check(fout, board, width) # Send output check
          
          # Record stats
          acm_iterations += tq.format_dict['total']
          acm_elapsed_time += tq.format_dict['elapsed']
        
        # Save game as a GIF
        acm.save_gif(encrypt_imgs, os.path.join(output_dir, 'encrypting.gif'), frame_dur=cfg['display']['frame_dur_ms'])
        acm.save_gif(decrypt_imgs, os.path.join(output_dir, 'decrypting.gif'), frame_dur=cfg['display']['frame_dur_ms'])

      ############## 
      # LAST : Generate the trace for this game: only check the last frame
      ##############
      elif acts["checks"] == "last":
        send_game_req(fout, board, acts['encrypt_key'], width, max_len) # Send initial data
        print(f'Generating expected result "{expected_fout}" ...')
        images = []
        # Simulate Game of Life
        with tqdm(range(acts['encrypt_key']), disable=False) as tq:
          for i in tq:
            add_image_to_list(images, board, cfg["display"])

            board, interm_en = acm.ArnoldCatEncryption(board)
            add_images_to_list(images, interm_en, cfg["display"])
            board, interm_de = acm.ArnoldCatDecryption(board)
            add_images_to_list(images, interm_de, cfg["display"])

          # Record stats
          acm_iterations += tq.format_dict['total']
          acm_elapsed_time += tq.format_dict['elapsed']
        add_image_to_list(images, board, cfg["display"]) # Add last frame
        print(f'\n\nLength of Images is: {len(images)}\n\n')
        # Save game as a GIF
        acm.save_gif(images, os.path.join(output_dir, expected_fout), frame_dur=cfg['display']['frame_dur_ms'])
        send_game_check(fout, board, width) # Send output check

      ############## 
      # ALL : Generate the trace for this game: check every frame a long the way
      ##############
      elif acts["checks"] == "all":
        print(f'Generating expected result "{expected_fout}" ...')
        images = []
        # Simulate Game of Life
        with tqdm(range(acts['encrypt_key']), disable=False) as tq:
          for i in tq:
            fout.write(f'# Checking frame {i+1}:\n')
            send_game_req(fout, board, 1, width, max_len) # Send next frame data (length=1)
            add_image_to_list(images, board, cfg["display"])

            board = acm.ArnoldCatEncryption(board)
            add_image_to_list(images, board, cfg["display"])
            board = acm.ArnoldCatDecryption(board)

            send_game_check(fout, board, width) # Send output check
        add_image_to_list(images, board, cfg["display"]) # Add last frame
        # Save output image
        acm.save_gif(images, os.path.join(output_dir, expected_fout), frame_dur=cfg['display']['frame_dur_ms'])
      
      # Invalid option
      else:
        assert False, f'ERROR: invalid "checks" option: {acts["checks"]}'
    
    # After all games finished...
    fout.write(f'########## SIMULATION FINISHED ##########\n')
    fout.write(f'0011____0_00000000000_{64*"0"}\n')
  
  # After output file closed...
  print('Done.')
  print()

  # Print performancs stats

  print('ACM script performance: (measured with "checks=last" games only)')
  print(f'   Computed and saved a total of {acm_iterations} ACM frames of size {width}x{width} over {acm_elapsed_time:.3f} seconds')
  if acm_elapsed_time==0 : acm_elapsed_time = float('nan') # Handle case where there were no 'last' games
  print(f'   Average performance {acm_iterations/acm_elapsed_time:.3f} frames/second')
  print()

if __name__ == '__main__':
  main()
